const ext = require('./templatesProvider.js');

const repo = ext.getRepositories();

repo.then(x => console.log(x));
