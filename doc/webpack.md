### Webpack

We assume here that Bootstrap and FontAwesome are already installed with Webpack.

Inspired by https://datatables.net/download and completed :

Add npm packages :
```sh
$ yarn add imports-loader
```
```sh
$ yarn add datatables.net
$ yarn add datatables.net-bs
$ yarn add datatables.net-buttons
$ yarn add datatables.net-buttons-bs
$ yarn add datatables.net-responsive
$ yarn add datatables.net-responsive-bs
$ yarn add datatables.net-select
$ yarn add datatables.net-select-bs
```

In `config/webpack/loaders/datatables.js` :

```js
module.exports = {
  test: /datatables\.net.*/,
  loader: 'imports-loader',
  options: {
    additionalCode: 'var define = false;'
  }
}
```

In `config/webpack/environment.js` :

```js
const { environment } = require('@rails/webpacker')
const datatables = require('./loaders/datatables')
environment.loaders.append('datatables', datatables)
module.exports = environment
```

in `app/javascript/pack/application.js` :

```js
// Load Datatables
require('datatables.net-bs')(window, $)
require('datatables.net-buttons-bs')(window, $)
require('datatables.net-buttons/js/buttons.colVis.js')(window, $)
require('datatables.net-buttons/js/buttons.html5.js')(window, $)
require('datatables.net-buttons/js/buttons.print.js')(window, $)
require('datatables.net-responsive-bs')(window, $)
require('datatables.net-select')(window, $)
// require('yadcf')(window, $) // Uncomment if you use yadcf (need a recent version of yadcf)
```
