import setup from './utils.js';

define([
  'react',
  'splunkjs/splunk',
], function (react, splunkjs) {
  const e = react.createElement;
  const input_labels = {
    stanza_name: 'Configuration entry name',
    console_addr: 'Console URL',
    projects: 'Projects',
    username: 'Username or Access Key',
    password: 'Password or Secret Key',
  }

  class SetupPage extends react.Component {
    constructor(props) {
      super(props);
      this.state = {
        stanza_name: '',
        console_addr: '',
        projects: '',
        username: '',
        password: '',
      };
      this.handleChange = this.handleChange.bind(this);
      this.handleSubmit = this.handleSubmit.bind(this);
    }

    handleChange(event) {
      this.setState({ [event.target.name]: event.target.value });
    }

    async handleSubmit(event) {
      event.preventDefault();
      await setup(splunkjs, this.state);
    }

    render() {
      return e('div', { className: 'setup' }, [
        e('form', { className: 'column right', onSubmit: this.handleSubmit }, [
          e('div', { className: 'field stanza_name' }, [
            e('label', { for: 'stanza_name' }, input_labels['stanza_name']),
            e('input', { type: 'text', name: 'stanza_name', value: this.state.stanza_name, onChange: this.handleChange, placeholder: 'My Console', required: true, pattern: '^[-_0-9A-Za-z ]+$' }),
          ]),
          e('div', { className: 'field console_addr' }, [
            e('label', { for: 'console_addr' }, input_labels['console_addr']),
            e('input', { type: 'url', name: 'console_addr', value: this.state.console_addr, onChange: this.handleChange, placeholder: 'https://console.example.com', required: true }),
          ]),
          e('div', { className: 'field projects' }, [
            e('label', { for: 'projects' }, `${input_labels['projects']} (leave blank for all)`),
            e('input', { type: 'text', name: 'projects', value: this.state.projects, onChange: this.handleChange, placeholder: 'Staging Tenant, Prod Tenant' }),
          ]),
          e('div', { className: 'field username' }, [
            e('label', { for: 'username' }, input_labels['username']),
            e('input', { type: 'text', name: 'username', value: this.state.username, onChange: this.handleChange, required: true }),
          ]),
          e('div', { className: 'field password' }, [
            e('label', { for: 'password' }, input_labels['password']),
            e('input', { type: 'password', name: 'password', value: this.state.password, onChange: this.handleChange, required: true }),
          ]),
          e('div', null, [
            e('button', { name: 'setup_button' }, 'Complete setup'),
          ]),
        ]),
        e('div', { className: 'column left' }, [
          e('div', { className: 'help_text' }, [
            e('h2', { className: 'underline' }, input_labels['stanza_name']),
            e('p', null, 'The name of the Console configuration entry.'),
            e('p', null, [
              'This value is used as the stanza name in ',
              e('code', null, 'twistlock/local/twistlock.conf'),
              ' and injected into the incident and forensic events to keep track of their sources. ',
              'You must use only alphanumeric, underscore, hyphen, and space characters (matches regex: ',
              e('code', null, '^[-_0-9A-Za-z ]+$'),
              ').',
            ]),
            e('p', null, 'To update an existing configuration entry, enter the existing configuration entry name with your updated values.'),
            e('h2', { className: 'underline' }, input_labels['console_addr']),
            e('p', null, 'The URL of your Compute Console.'),
            e('p', null, [
              'If you\'re using SaaS, this will be the cloud.twistlock.com address, not the prismacloud.io address. See ',
              e('a', { href: 'https://prisma.pan.dev/api/cloud/cwpp/how-to-eval-console#for-saas-installations' }, 'here'),
              ' for more details.',
            ]),
            e('h2', { className: 'underline' }, input_labels['projects']),
            e('p', null, [
              e('i', null, 'Self-hosted Compute only. '),
              'A comma-separated list of projects to be polled. Leave blank to query all projects.',
            ]),
            e('p', null, 'Example: Central Console, Staging Tenant, Prod Tenant'),
            e('h2', { className: 'underline' }, input_labels['username']),
            e('p', null, 'The username of your Compute user.'),
            e('p', null, [
              'If you\'re using SaaS, this will be an ',
              e('a', { href: 'https://docs.paloaltonetworks.com/prisma/prisma-cloud/prisma-cloud-admin-compute/authentication/access_keys.html' }, 'access key'),
              '.',
            ]),
            e('h2', { className: 'underline' }, input_labels['password']),
            e('p', null, 'The password of your Compute user'),
            e('p', null, [
              'If you\'re using SaaS, this will be a ',
              e('a', { href: 'https://docs.paloaltonetworks.com/prisma/prisma-cloud/prisma-cloud-admin-compute/authentication/access_keys.html' }, 'secret key'),
              '.',
            ]),
          ]),
        ]),
      ]);
    }
  }

  return e(SetupPage);
});
