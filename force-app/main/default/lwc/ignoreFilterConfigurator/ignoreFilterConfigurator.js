/**
 * Custom UI that allows users to configure the behavior of the Ignore Filter extension for the Valence platform.
 */

import {track} from 'lwc';
import ValenceConfigurator from 'c/valenceConfigurator';

export default class IgnoreFilterConfigurator extends ValenceConfigurator {

	@track choices;

	conditionOptions = [{label : 'MUST', value : 'MUST'}, {label : 'MUST NOT', value : 'MUST NOT'}];

	// overridden from ValenceConfigurator
	setConfig(config) {

		// set some default values
		this.configuration.condition = config.condition || 'MUST';
		this.configuration.ignoreReason = config.ignoreReason || '';
		this.configuration.values = config.values || [];

		// parse existing choices
		this.choices = [];
		this.configuration.values.forEach(choiceVal => this.choices.push(this.createChoice(choiceVal)));
	}

	updateCondition(event) {
		this.configuration.condition = event.target.value;
		this.update();
	}

	addChoice() {
		this.choices.push(this.createChoice(''));
		this.configuration.values.push('');
		this.update();
	}

	createChoice(choiceValue) {
		return {'key' : Math.random(), 'value' : choiceValue};
	}

	choiceUpdated(event) {
		let index = event.target.dataset.index;
		this.choices[index].value = event.target.value;
		this.configuration.values[index] = event.target.value;
		this.update();
	}

	removeChoice(event) {
		let index = event.target.value;
		this.choices.splice(index, 1);
		this.configuration.values.splice(index, 1);
		this.update();
	}

	updateReason(event) {
		this.configuration.ignoreReason = event.target.value;
		this.update();
	}

	// overridden from ValenceConfigurator
	getValid() {
		return this.choices.length !== 0 && this.configuration.ignoreReason !== '';
	}
}