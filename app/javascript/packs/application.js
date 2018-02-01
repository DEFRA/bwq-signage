import 'babel-polyfill';
import Vue from 'vue';
// import Raven from 'raven-js';
// import RavenVue from 'raven-js/plugins/vue';
import App from '../app.vue';

// if (process.env.NODE_ENV === 'production') {
//   // Sentry.io logging
//   Raven
//     .config('https://daf8ef74d566436cb12e4b5c4293ec37@sentry.io/215384')
//     .addPlugin(RavenVue, Vue)
//     .install();
// }

// router hooks

document.addEventListener('DOMContentLoaded', () => {
  /* eslint-disable no-new */
  new Vue({
    el: '#bwq-signage-application',
    template: '<App/>',
    components: { App },
  });
});
