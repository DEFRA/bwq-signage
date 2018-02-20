// /usr/bin/env node

/** NodeJS script to render a web page to a .pdf file using Chrome Headless.
 * Options:
 *   node save-pdf.js <url> [a3|a4] [landscape|portrait] <output-file>
 */

const puppeteer = require('puppeteer');

const url = process.argv[2];
const format = process.argv[3];
const isLandscape = process.argv[4] === 'landscape';
const path = process.argv[5];

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/chromium-browser',
    headless: true,
  });
  const page = await browser.newPage();
  await page.goto(url, { waitUntil: 'networkidle0' });

  await page.pdf({
    path,
    format,
    isLandscape,
    printBackground: true,
  });

  await browser.close();
})()
  .then(() => {
    process.exit(0);
  })
  .catch((e) => {
    console.log('Puppeteer failed with: ', e); // eslint-disable-line no-console
    process.exit(1);
  });
