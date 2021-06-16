const basePath = '../app/twistlock/javascript';

require.config({
  paths: {
    app: `${basePath}/components/app`,
    SplunkService: `${basePath}/components/splunk_service`,
    utils: `${basePath}/components/utils`,
    react: [
      'https://unpkg.com/react@17/umd/react.production.min',
      `${basePath}/vendor/react.production.min`,
    ],
    ReactDOM: [
      'https://unpkg.com/react-dom@17/umd/react-dom.production.min',
      `${basePath}/vendor/react-dom.production.min`,
    ],
  },
  scriptType: 'module',
});

require([
  'app',
  'ReactDOM',
], (app, ReactDOM) => {
  ReactDOM.render(app, document.getElementById('container'));
});