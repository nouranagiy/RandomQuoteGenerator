# LingoLearn — Firebase Cloud Functions (pronunciation token endpoint)

Deploys a small Cloud Function that mints short-lived Azure Speech access
tokens so the app never needs the Azure key. The app sends the audio to the
Azure Speech Recognition endpoint; this function only provides the token.

## Before deploy

Create the Azure Speech resource and set three secrets:

```bash
firebase functions:secrets:set AZURE_SPEECH_REGION
firebase functions:secrets:set AZURE_SPEECH_RESOURCE
firebase functions:secrets:set AZURE_SPEECH_KEY
```

`AZURE_SPEECH_REGION` example: `eastus` (the region your resource lives in).
`AZURE_SPEECH_RESOURCE` is the resource name (the app consumes
`https://<resource>.cognitiveservices.azure.com/...`).
`AZURE_SPEECH_ENDPOINT` can be set as a secret too when a custom endpoint is
required.

The Functions Framework reads secrets as environment variables, so no Azure
credentials are committed or shipped to the client.

## Deploy

```bash
npm install
firebase deploy --only functions --project lingolearn-9cc40
```

## Wire the app

Deploy the functions, then find the token URL printed by
`firebase functions:list` (it ends with `/token`), and run the app with:

```bash
flutter run --dart-define=LINGOLEARN_AZURE_TOKEN_URL=https://.../token
```

The app calls `GET <tokenURL>?language=<lang>&format=detailed`, gets
`{ token, endpoint, expiresInSeconds }`, and posts the recorded WAV to
`<endpoint>` with the returned bearer token and the `Pronunciation-Assessment`
header. No API key ever leaves the backend.

## Verify

`GET /health` returns `{ "ok": true }`.