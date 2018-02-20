import 'babel-polyfill';
import Raven from 'raven-js';
import initialiseMap from '../lib/sampling-point-map';

if (process.env.NODE_ENV === 'production') {
  // Sentry.io logging - captures run-time error messages
  Raven
    .config('https://a893b64b570a4af38a6d410c935a0bea@sentry.io/281446')
    .install();
}

document.addEventListener('DOMContentLoaded', () => {
  try {
    initialiseMap();
  } catch (error) {
    Raven.captureException(error);
  }
});
