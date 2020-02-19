({
	updateConfig : function(component, event, helper) {
		component.set('v.configuration', event.getParam('configuration'));
	},

	updateValid : function(component, event, helper) {
		component.set('v.isValid', event.getParam('isValid'));
		component.set('v.isDirty', true);
	}
});