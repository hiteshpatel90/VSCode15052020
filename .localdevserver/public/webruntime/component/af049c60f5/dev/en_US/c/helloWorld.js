Webruntime.moduleRegistry.define('c/helloWorld', ['lwc'], function (lwc) { 'use strict';

    function tmpl($api, $cmp, $slotset, $ctx) {
      return [];
    }

    var _tmpl = lwc.registerTemplate(tmpl);
    tmpl.stylesheets = [];
    tmpl.stylesheetTokens = {
      hostAttribute: "lwc-helloWorld_helloWorld-host",
      shadowAttribute: "lwc-helloWorld_helloWorld"
    };

    class HelloWorld extends lwc.LightningElement {}

    var helloWorld = lwc.registerComponent(HelloWorld, {
      tmpl: _tmpl
    });

    return helloWorld;

});
