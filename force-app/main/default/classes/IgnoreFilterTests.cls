/**
 * Exercises the IgnoreFilter class.
 */
@IsTest
private class IgnoreFilterTests {

	@IsTest static void testMust() {

		// setup up an artificial Context to use for our test
		valence.LinkContext context = new valence.LinkContext();
		context.linkSourceName = 'Alpha';
		context.mappings = new Map<String, valence.Mapping>{
			'firstMapping' => new Valence.Mapping('firstMapping','Employer','Company', null),
			'secondMapping' => new Valence.Mapping('secondMapping','PersonName','LastName',null),
			'thirdMapping' => new Valence.Mapping('thirdMapping','Industry','Sector','{"condition":"MUST","values":["Explosives","Space Exploration"],"ignoreReason":"This industry is dangerous."}')
		};

		List<valence.RecordInFlight> records = new List<valence.RecordInFlight>{
			new valence.RecordInFlight(new Map<String, Object>{
				'Employer' => '12',
				'PersonName' => 'George',
				'Industry' => 'Agriculture'
			}),
			new valence.RecordInFlight(new Map<String, Object>{
				'Employer' => '10',
				'PersonName' => 'Sally',
				'Industry' => 'Space Exploration'
			})
		};

		Test.startTest();
		new IgnoreFilter().process(context, records);
		Test.stopTest();

		System.assertEquals(2, records.size());
		System.assertEquals(true, records[0].isIgnored());
		System.assertEquals(false, records[1].isIgnored());
	}

	@IsTest static void testMustNot() {

		// setup up an artificial Context to use for our test
		valence.LinkContext context = new valence.LinkContext();
		context.linkSourceName = 'Alpha';
		context.mappings = new Map<String, valence.Mapping>{
			'firstMapping' => new Valence.Mapping('firstMapping','Employer','Company',null),
			'secondMapping' => new Valence.Mapping('secondMapping','PersonName','LastName',null),
			'thirdMapping' => new Valence.Mapping('thirdMapping','Industry','Sector','{"condition":"MUST NOT","values":["Explosives","Space Exploration"],"ignoreReason":"This industry is dangerous."}')
		};

		List<valence.RecordInFlight> records = new List<valence.RecordInFlight>{
			new valence.RecordInFlight(new Map<String, Object>{
				'Employer' => '12',
				'PersonName' => 'George',
				'Industry' => 'Agriculture'
			}),
			new valence.RecordInFlight(new Map<String, Object>{
				'Employer' => '10',
				'PersonName' => 'Sally',
				'Industry' => 'Space Exploration'
			})
		};

		Test.startTest();
		new IgnoreFilter().process(context, records);
		Test.stopTest();

		System.assertEquals(2, records.size());
		System.assertEquals(false, records[0].isIgnored());
		System.assertEquals(true, records[1].isIgnored());
	}

	@IsTest static void testNoConfigs() {

		// setup up an artificial Context to use for our test
		valence.LinkContext context = new valence.LinkContext();
		context.linkSourceName = 'Alpha';
		context.mappings = new Map<String, valence.Mapping>{
			'firstMapping' => new Valence.Mapping('firstMapping','Employer','Company', null),
			'secondMapping' => new Valence.Mapping('secondMapping','PersonName','LastName',null),
			'thirdMapping' => new Valence.Mapping('thirdMapping','Industry','Sector',null)
		};

		List<valence.RecordInFlight> records = new List<valence.RecordInFlight>{
			new valence.RecordInFlight(new Map<String, Object>{
				'Employer' => '12',
				'PersonName' => 'George',
				'Industry' => 'Agriculture'
			}),
			new valence.RecordInFlight(new Map<String, Object>{
				'Employer' => '10',
				'PersonName' => 'Sally',
				'Industry' => 'Space Exploration'
			})
		};

		Test.startTest();
		new IgnoreFilter().process(context, records);
		Test.stopTest();

		System.assertEquals(2, records.size());
		System.assertEquals(false, records[0].isIgnored());
		System.assertEquals(false, records[1].isIgnored());
	}

	@IsTest static void testRestrictions() {

		System.assertEquals(true, new IgnoreFilter().validFor(null));
	}

	@IsTest static void testConfigurationMethods() {

		IgnoreFilter filter = new IgnoreFilter();

		System.assertNotEquals(null, filter.getMappingConfigurationLightningComponent());
		System.assertEquals(null, filter.getMappingConfigurationStructure());

		String config = JSON.serialize(new Map<String, Object> {
			'condition' => 'MUST NOT',
			'values' => new Set<String>{'Explosives','Space Exploration'},
			'ignoreReason' => 'This industry is dangerous.'
		});

		System.assertEquals('In order to not be ignored, record values MUST NOT be one of these: {Explosives, Space Exploration}', filter.explainMappingConfiguration(config));
	}
}