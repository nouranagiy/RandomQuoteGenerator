const express = require('express');

const app = express();
const port = process.env.PORT || 3000;

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


let cached = { token: null, tokenExpiresAt: 0 };

async function getToken() {
  const now = Date.now();
  
  if (cached.token && now < cached.tokenExpiresAt - 60_000) {
    return cached.token;
  }
  const token = await fetchStsToken();
  cached = { token, tokenExpiresAt: now + 9 * 60_000 };
  return token;
}

app.get('/token', async (_req, res) => {
  try {
    const token = await getToken();
    res.json({
      token,
      endpoint: regionEndpoint(),
      expiresInSeconds: 540,
    });
  } catch (err) {
    console.error('[token] failed:', err.message);
    res.status(502).json({ error: 'unable to acquire an Azure Speech token' });
  }
});

app.get('/health', (_req, res) => res.json({ ok: true }));

app.listen(port, () => {
  console.log(`LingoLearn token endpoint listening on :${port}`);
});