# LingoLearn Azure Speech token endpoint

A tiny server that mints short-lived Azure Speech tokens so the Flutter app never
contains a long-lived Azure key.

**App contract** (must not change):

```
GET /token
200 application/json
{
  "token": "<jwt>",
  "endpoint": "https://<resource>.cognitiveservices.azure.com/stt/speech/recognition/conversation/cognitiveservices/v1",
  "expiresInSeconds": 540
}
```

The app appends `?language=<code>&format=detailed` to `endpoint` itself and sends the
audio with `Authorization: Bearer <token>`.

## Setup

1. Create an **Azure AI Speech** resource in the [Azure portal](https://portal.azure.com)
   and copy its **key** and **region / resource name**.
2. Install and start:

   ```bash
   npm install
   node server.js
   ```

3. Access the endpoint to confirm it works:
   `GET http://localhost:3000/token`

## Environment variables

| Variable              | Required | Purpose                                                            |
| --------------------- | -------- | ------------------------------------------------------------------ |
| `AZURE_SPEECH_REGION` | Yes      | Azure region, e.g. `eastus`                                        |
| `AZURE_SPEECH_RESOURCE` | Yes    | Speech resource short name (used to build the app endpoint)        |
| `AZURE_SPEECH_KEY`    | Yes      | Server-side only; never commit it or ship it in the app            |
| `AZURE_SPEECH_ENDPOINT` | No     | Override the exact base URL handed to the app                      |
| `PORT`                | No       | Listen port (default `3000`)                                       |

## Security notes

- The Azure key lives **only** here (env var / secret store) and is never sent to the app.
- The STS token returned is short-lived (<10 min), scoped to your Speech resource.
- Deploy behind HTTPS (the app talks to it over the network).
- Add rate limiting / auth on `/token` before exposing it publicly (anyone with the URL
  can mint tokens while the key is valid — the key's blast radius is one Speech resource,
  but rate limits are recommended).

## Pointing the Flutter app at it

```bash
flutter run \
  --dart-define=LINGOLEARN_AZURE_TOKEN_URL=https://your-host/token \
  --dart-define=LINGOLEARN_AZURE_LANGUAGE=en-US
```

See the main `README.md` for details.