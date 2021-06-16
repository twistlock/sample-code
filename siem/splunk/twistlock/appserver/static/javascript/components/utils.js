export default async function setup(splunkjs, options) {
  async function insertPassword(appNamespace, config) {
    const storedPasswords = splunkSvc.storagePasswords(appNamespace);
    // Delete existing password so creation ("update" from user perspective) will work.
    // The Splunk SDK does not have a way to update passwords as far as I can tell.
    await storedPasswords.fetch((err, res) => {
      const passwords = res.list()
      for (let i = 0; i < passwords.length; i++) {
        if (passwords[i].name === `${config.realm}:${config.name}:`) {
          passwords[i].remove();
          break;
        }
      }
    });
    await storedPasswords.create(config);
  }

  async function reloadApp(app) {
    const apps = await splunkSvc.apps();
    await apps.fetch();
    await apps.item(app).reload();
    window.location.href = '/app/twistlock';
  }

  async function updateConfFile(appNamespace, fileName, config) {
    const { stanza_name, ...props } = config;

    // Get config file
    const confFiles = splunkSvc.configurations(appNamespace);
    await confFiles.fetch();
    let confFile = await confFiles.item(fileName);
    if (!confFile) {
      await confFiles.create(fileName);
      await confFiles.fetch();
      confFile = await confFiles.item(fileName);
    }
    await confFile.fetch();

    // Get stanza
    let stanza = await confFile.item(stanza_name);
    if (!stanza) {
      await confFile.create(stanza_name);
      await confFile.fetch();
      stanza = await confFile.item(stanza_name);
    }
    await stanza.fetch();

    await stanza.update(props);
  }

  // Basic sanitizer
  function sanitizeOptions(options) {
    let sanitizedOptions = {};
    for (const [key, value] of Object.entries(options)) {
      sanitizedOptions[key] = value.trim();
    }
    // Trims all whitespace around commas
    sanitizedOptions['projects'] = options['projects'].split(/\s*,\s*/).join().trim();
    return sanitizedOptions;
  }

  const splunkSvc = new splunkjs.Service(new splunkjs.SplunkWebHttp());

  const appNamespace = {
    owner: 'nobody',
    app: 'twistlock',
    sharing: 'app',
  };

  const sanitizedOptions = sanitizeOptions(options);
  
  await insertPassword(appNamespace, {
    name: sanitizedOptions.username,
    password: sanitizedOptions.password,
    realm: sanitizedOptions.stanza_name,
  });
  delete sanitizedOptions.password;
  await updateConfFile(appNamespace, appNamespace.app, sanitizedOptions);
  await updateConfFile(appNamespace, 'app', {
    stanza_name: 'install',
    is_configured: 'true',
  });
  await reloadApp(appNamespace.app);
}
