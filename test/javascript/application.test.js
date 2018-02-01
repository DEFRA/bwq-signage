import { mount } from 'vue-test-utils';
import App from '../../app/javascript/app.vue';

describe('Application', () => {
  const app = mount(App);

  it('demonstrates that tests are working', () => {
    expect(app.html().length).not.toBe(0);
  });
});
