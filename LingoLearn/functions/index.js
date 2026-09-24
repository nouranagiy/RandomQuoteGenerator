const functions = require('firebase-functions');
const {onRequest} = require('firebase-functions/v2/https');
const logger = require('firebase-functions/logger');

const region = process.env.AZURE_SPEECH_REGION;
const resource = process.env.AZURE_SPEECH_RESOURCE;
const key = process.env.AZURE_SPEECH_KEY;

function regionEndpoint() {
  const defaultEndpoint = resource
    ? `https://${resource}.cognitiveservices.azure.com/stt/speech/recognition/conversation/cognitiveservices/v1`
    : `https://${region}.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1`;
  return process.env.AZURE_SPEECH_ENDPOINT || defaultEndpoint;
}

async function fetchStsToken() {
  const stsUrl = `https://${region}.api.cognitive.microsoft.com/sts/v1.0/issueToken`;
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 10000);
  try {
    const response = await fetch(stsUrl, {
      method: 'POST',
      headers: {
        'Ocp-Apim-Subscription-Key': key,
        'Content-Length': '0',
      },
      signal: controller.signal,
    });
    if (!response.ok) {
      throw new Error(`STS endpoint returned HTTP ${response.status}`);
    }
    const token = (await response.text()).trim();
    if (!token) {
      throw new Error('STS endpoint returned an empty token');
    }
    return token;
  } finally {
    clearTimeout(timer);
  }
}

let cached = {token: null, tokenExpiresAt: 0};

async function getToken() {
  const now = Date.now();
  if (cached.token && now < cached.tokenExpiresAt - 60_000) {
    return cached.token;
  }
  const token = await fetchStsToken();
  cached = {token, tokenExpiresAt: now + 9 * 60_000};
  return token;
}

exports.token = onRequest(async (req, res) => {
  if (req.method !== 'GET') {
    res.status(405).json({error: 'method not allowed'});
    return;
  }
  try {
    const token = await getToken();
    res.json({
      token,
      endpoint: regionEndpoint(),
      expiresInSeconds: 540,
    });
  } catch (err) {
    logger.error('[token] failed:', err.message);
    res.status(502).json({error: 'unable to acquire an Azure Speech token'});
  }
});

exports.health = onRequest((req, res) => {
  res.json({ok: true});
});