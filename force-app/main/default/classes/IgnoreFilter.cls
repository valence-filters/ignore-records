/**
 * Generic Valence filter designed to give admins flexibility in designing ignore behavior for Links.
 */
global with sharing class IgnoreFilter implements valence.TransformationFilter, valence.ConfigurablePerMappingFilter {

	public String getMappingConfigurationLightningComponent() {
		return 'c:IgnoreFilterWrapper';
	}

	public String getMappingConfigurationStructure() {
		return null;
	}

	public String explainMappingConfiguration(String configStr) {
		String explanation = 'In order to not be ignored, record values {0} be one of these: {1}';
		Configuration config = (Configuration)JSON.deserialize(configStr, Configuration.class);
		return String.format(explanation, new List<String>{config.condition, String.valueOf(config.values)});
	}

	public Boolean validFor(valence.LinkContext context) {
		return true;
	}

	public void process(valence.LinkContext context, List<valence.RecordInFlight> records) {

		Map<String, Configuration> configsBySourceField = new Map<String, Configuration>();

		/*
		 * Assemble any configs that have been set up by admins.
		 */
		for(valence.Mapping mapping : context.mappings.values()) {

			// skip blank configurations
			if(String.isNotBlank(mapping.configuration)) {
				Configuration config = (Configuration)JSON.deserialize(mapping.configuration, Configuration.class);
				configsBySourceField.put(mapping.sourceFieldName, config);
			}
		}

		// bail out if we didn't find any
		if(configsBySourceField.isEmpty()) {
			return;
		}

		/*
		 * Iterate through our records, ignoring where appropriate.
		 */
		for(valence.RecordInFlight record : records) {
			for(String sourceField : configsBySourceField.keySet()) {
				Configuration config = configsBySourceField.get(sourceField);
				String value = String.valueOf(record.getOriginalProperties().get(sourceField));
				if(value != null) {
					if('MUST'.equalsIgnoreCase(config.condition)) {
						if(!config.values.contains(value)) {
							record.ignore(config.ignoreReason);
						}
					}
					else if('MUST NOT'.equalsIgnoreCase(config.condition)) {
						if(config.values.contains(value)) {
							record.ignore(config.ignoreReason);
						}
					}
				}
			}
		}
	}

	/**
	 * Simple class for holding the configuration needed for this filter.
	 */
	private class Configuration {

		private String condition;
		private Set<String> values;
		private String ignoreReason;
	}
}