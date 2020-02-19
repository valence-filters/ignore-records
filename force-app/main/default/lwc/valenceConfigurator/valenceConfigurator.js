/**
 * This component is meant to be extended when you are implementing a custom UI configurator for Valence.
 */

import {api, LightningElement} from 'lwc';

export default class ValenceConfigurator extends LightningElement {

	@api set publicConfig(config) {

		this.configuration = {};

		if(config === null)
			return;

		this.setConfig(config);
	}

	get publicConfig() {
		throw 'Why is this required?';
	}

	/**
	 * Call this method when you make changes that merit checking validity and possibly updating the config.
	 */
	update() {
		let isValid = this.getValid();
		this.dispatchEvent(new CustomEvent('updatevalid', {detail : {'isValid' : isValid}}));

		if(isValid) {
			this.dispatchEvent(new CustomEvent('updateconfig', {detail : {'configuration' : this.configuration}}));
		}
	}

	/**
	 * Override this method to be handed starting configurations. This method will be called repeatedly (many times)
	 * while your component exists. Once at the start, and then throughout as the configuration is changed.
	 */
	setConfig(config) {
		throw 'You must implement a setConfig() method.';
	}

	/**
	 * Override this method to calculate the validity of your current state, returning true if you're happy with it and false if you're not.
	 */
	getValid() {
		throw 'You must implement a getValid() method.';
	}
}