'use strict';

document.addEventListener('DOMContentLoaded', () => {
  var checkboxes = document.getElementsByTagName('paper-checkbox');
  var preferences = {};
  var sources = [];
  for (let checkbox of checkboxes) {
    let preference = new Preference(checkbox.getAttribute('name'));
    preferences[preference.name] = preference;
    let source = Rx.Observable.fromEvent(checkbox, 'change');
    sources.push(source);
  }
  sources.forEach(source => {
    let stream = source.map(event => event.currentTarget);
    stream.subscribe(checkbox => {
      let name = checkbox.getAttribute('name');
      let preference = preferences[name];
      preference.enabled = checkbox.checked;
      console.log(preference);
    });
  });
})

class Preference {
  constructor(name) {
    this.name = name;
    this.enabled = false;
  }
}
