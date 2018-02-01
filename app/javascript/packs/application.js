import 'babel-polyfill';
import Vue from 'vue';
import Raven from 'raven-js';
import RavenVue from 'raven-js/plugins/vue';
import App from '../app.vue';

if (process.env.NODE_ENV === 'production') {
  // Sentry.io logging - captures run-time error messages
  Raven
    .config('https://a893b64b570a4af38a6d410c935a0bea@sentry.io/281446')
    .addPlugin(RavenVue, Vue)
    .install();
}

// wait until the DOM is rendered before we initialise Vue
document.addEventListener('DOMContentLoaded', () => {
  /* eslint-disable no-new */
  new Vue({
    el: '#bwq-signage-application',
    template: '<App/>',
    components: { App },
  });
});
