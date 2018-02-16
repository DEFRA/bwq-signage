import 'babel-polyfill';
import Vue from 'vue';
import Raven from 'raven-js';
import RavenVue from 'raven-js/plugins/vue';
import SamplingPointMap from '../components/sampling-point-map.vue';

// if (process.env.NODE_ENV === 'production') {
//   // Sentry.io logging - captures run-time error messages
//   Raven
//     .config('https://a893b64b570a4af38a6d410c935a0bea@sentry.io/281446')
//     .addPlugin(RavenVue, Vue)
//     .install();
// }

// wait until the DOM is rendered before we initialise Vue
document.addEventListener('DOMContentLoaded', () => {
  try {
    console.log('In domContentLoaded event handler.', process.env.NODE_ENV === 'production');
    debugger;
    /* eslint-disable no-new */
    new Vue({
      el: '#map-container',
      template: '<SamplingPointMap/>',
      components: { SamplingPointMap },
    });
  } catch (error) {
    console.log('caught', error);
  }
});
