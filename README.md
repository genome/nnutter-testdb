# testdb

#### Table of Contents

1. [Overview](#overview)
2. [Limitations - OS compatibility, etc.](#limitations)
3. [Development - Guide for contributing to the module](#development)

## Overview

This module provisions a standalone TestDbServer instance.

## Limitations

`testdb` is not well tested and should not be used without great care.

## Development

To run acceptance tests:

```
$ bundle install
$ bundle exec rspec spec/acceptance
```
