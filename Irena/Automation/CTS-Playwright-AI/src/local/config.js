module.exports = {
  web: {
    baseURL: 'https://cts.nexdev.net/main',
    usr: 'irena',
    pwd: '288105',
  },
  db: {
    ctsmain: {
      host: '10.18.200.70',
      port: 3307,
      usr: 'irena.vn',
      pwd: '123456'
    },
    ctsarchive: {
      host: '10.18.200.71',
      port: 3307,
      usr: 'irena.vn',
      pwd: '123456'
    },
    dbcust: {
      host: '10.18.200.54',
      port: 1433,
      usr: 'testteam',
      pwd: '@quality#'
    },
    db053: {
      host: '10.18.200.58',
      port: 1433,
      usr: 'testteam',
      pwd: '@quality#'
    },
    dbpro: {
      host: '10.18.200.17',
      port: 1433,
      usr: 'testteam',
      pwd: '@quality#'
    },
    dbtrans: {
      host: '10.18.200.55',
      port: 1433,
      usr: 'testteam',
      pwd: '@quality#'
    },
    db061: {
      host: '10.18.200.56',
      port: 1433,
      usr: 'sputeam',
      pwd: '@sputeam#'
    },
    db055: {
      host: '10.18.200.57',
      port: 1433,
      usr: 'testteam',
      pwd: '@quality#'
    },
    dbgrp01l: {
      host: '10.18.200.69',
      port: 1433,
      usr: 'testteam',
      pwd: '@quality#'
    }
  },
  api: {
  },
  testSuites: {
    smoke: [
      'login__login',
      'home__search'
    ],
    regression: [
      'login__login',
      'home__search',
      'account-profile__mark-category',
      'association-detection__detect'
    ],
    full: [
      'login__login',
      'home__search',
      'account-profile__mark-category',
      'account-profile__unmark-category',
      'association-detection__detect',
      'association-detection__check-tablegrid',
      'problem-account-management__mark-new',
      'problem-account-management__unmark',
      'problem-account-management__check-tablegrid'
    ]
  }
};