// /usr/bin/env node

/** NodeJS script to render a web page to a .pdf file using Chrome Headless.
 * Options:
 *   node save-pdf.js <url> [a3|a4] [landscape|portrait] <output-file>
 */
const { argv } = process;

const puppeteer = require('puppeteer');

const url = argv[2];
const format = argv[3];
const isLandscape = argv[4] === 'landscape';
const path = argv[5];

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
    landscape: isLandscape,
    printBackground: true,
    pageRanges: '1',
  });

  await browser.close();
})()
  .then(() => {
    process.exit(0);
  })
  .catch(() => {
    process.exit(1);
  });
