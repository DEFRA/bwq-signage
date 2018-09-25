[![Build Status](https://travis-ci.org/DEFRA/bwq-signage.svg?branch=master)](https://travis-ci.org/DEFRA/bwq-signage)
[![Build Status](https://travis-ci.org/DEFRA/bwq-signage.svg?branch=develop)](https://travis-ci.org/DEFRA/bwq-signage)
[![Coverage Status](https://coveralls.io/repos/github/DEFRA/bwq-signage/badge.svg?branch=develop&service=github)](https://coveralls.io/github/DEFRA/bwq-signage?branch=develop)

# BWQ Signage project

This tool is being developed by Epimorphics on behalf of EA and Defra. We will
provide a web application for generating standardised bathing water signage for
designated bathing waters in England.

Project officer: Tamsin Appleton, EA

## License

[Government Licence v3.0](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3)

## Code of conduct

Please note that this project is released with a [Contributor Code of Conduct](code-of-conduct.md).
By participating in this project you agree to abide by its terms.

# Overview

This is a fairly straightforward Rails application, with the exception that there is no back-end database.
Details of bathing waters to be displayed on signage are obtained from the bathing water quality
[linked-data API](http://environment.data.gov.uk/bwq/doc/api-reference-v0.6.html). The only other
state that is stored is the logos of local authorities, so that bathing water controllers
from LA's only need to upload their authority's logo once. These logos are stored
on an Amazon S3 bucket.

## Actions

Install:

    git clone git@github.com:DEFRA/bwq-signage.git
    cd bwq-signage
    bundle

Test:

    rails test

Note that the PDF download test currently requires the application to be running on
`localhost`, as the test uses Chrome headless to visit the page and convert rendered HTML
to PDF. This test is disabled in Travis. To run during development, ensure that
`rails server` is running in another terminal.

## Logo management

Local authority logos are cached in S3. See `services/logo_manager.rb` for details. AWS
credentials are managed via `config/initializers/aws.rb`. Currently, production AWS
credentials are configured separately via the deployment automation scripts.
