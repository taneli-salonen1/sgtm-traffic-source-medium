___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Traffic Source / Medium",
  "categories": ["UTILITY", "ATTRIBUTION", "ANALYTICS"],
  "description": "Returns Google Analytics like source / medium information on the source of traffic. Includes referral exclusions as well as mapping of common search engines and social referrers.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "urlInput",
    "displayName": "URL Source",
    "macrosInSelect": true,
    "selectItems": [
      {
        "value": "page_location",
        "displayValue": "page_location"
      }
    ],
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "help": "A valid URL that the variable will use to read the utm tags from, for example.",
    "defaultValue": "page_location",
    "alwaysInSummary": true
  },
  {
    "type": "SELECT",
    "name": "referrerSource",
    "displayName": "Referring URL Source",
    "macrosInSelect": true,
    "selectItems": [
      {
        "value": "page_referrer",
        "displayValue": "page_referrer"
      }
    ],
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "help": "A valid URL that identifies the referring source of traffic.",
    "defaultValue": "page_referrer",
    "alwaysInSummary": true
  },
  {
    "type": "SIMPLE_TABLE",
    "name": "referralExclusion",
    "displayName": "Excluded Referral Domains",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "Domain",
        "name": "domain",
        "type": "TEXT"
      }
    ],
    "newRowButtonText": "Add Domain",
    "alwaysInSummary": true,
    "help": "List all domain names to be excluded as referrals. Variable will return undefined. Enter the full domain or top-level domain."
  },
  {
    "type": "LABEL",
    "name": "label1",
    "displayName": "Enter either the whole domain name or top-level domain."
  }
]


___SANDBOXED_JS_FOR_SERVER___

const log = require('logToConsole');
const parseUrl = require('parseUrl');
const getEventData = require('getEventData');
const computeEffectiveTldPlusOne = require('computeEffectiveTldPlusOne');


// list of social referrer tld patterns (begins with)
const socialReferrers = [
  {tld: 'facebook.com', platform: 'facebook'},
  {tld: 'twitter.com', platform: 'twitter'},
  {tld: 't.co', platform: 'twitter'},
  {tld: 'linkedin.com', platform: 'linkedin'},
  {tld: 'lnkd.in', platform: 'linkedin'},
  {tld: 'instagram.com', platform: 'instagram'},
  {tld: 'pinterest.', platform: 'pinterest'},
  {tld: 'linkedin.android', platform: 'linkedin'},
  {tld: 'telegram.messenger', platform: 'telegram'},
  {tld: 'com.slack', platform: 'slack'},
];

// list of search engine tld patterns (begins with)
const searchEngines = [
  {tld: 'duckduckgo.', platform: 'duckduckgo'},
  {tld: 'google.', platform: 'google'},
  {tld: 'yahoo.', platform: 'yahoo'},
  {tld: 'bing.', platform: 'bing'},
  {tld: 'yandex.', platform: 'yandex'},
  {tld: 'baidu.', platform: 'baidu'},
  {tld: 'naver.', platform: 'naver'}
];

// parse the current page's url  
const parsedUrl = data.urlInput === 'page_location' ? 
      parseUrl(getEventData('page_location')) : parseUrl(data.urlInput);

// get the referring url
const referrerUrl = data.referrerSource === 'page_referrer' ? 
      getEventData('page_referrer') : data.referrerSource;

const referrerDomain = parseUrl(referrerUrl) ? parseUrl(referrerUrl).hostname : null;
const referrerTLD = referrerUrl ? computeEffectiveTldPlusOne(referrerUrl) : null;

// list of excluded domains, either full or tld
const exludedDomains = data.referralExclusion ? data.referralExclusion.map(obj => {
  return obj.domain;
}) : [];

// check if the refferring domain is excluded and return undefined
if (exludedDomains.length > 0 && 
    (exludedDomains.indexOf(referrerDomain) !== -1 || exludedDomains.indexOf(referrerTLD) !== -1)) {

  return;
}

// a function for returning a source / medium string
const sourceMedium = (source, medium) => {
  const sourceString = source || '(not set)';
  const mediumString = medium || '(not set)';
  return sourceString + ' / ' + mediumString;
};

// continue if the input url was valid
if (parsedUrl) {
  const topLevelDomain = computeEffectiveTldPlusOne(parsedUrl.href);
  
  // included url parameters
  const utmSource = parsedUrl.searchParams.utm_source;
  const utmMedium = parsedUrl.searchParams.utm_medium;
  const gclid = parsedUrl.searchParams.gclid;
  const gclsrc = parsedUrl.searchParams.gclsrc;

  if (utmSource || utmMedium) {
    // utm tags were used
    return sourceMedium(utmSource, utmMedium);
    
  } else if (gclid || ['aw.ds', 'ds', '', ].indexOf(gclsrc) !== -1) {
    // gclid or gclsrc parameter in the url
    // https://support.google.com/searchads/answer/7342044?hl=en
    return sourceMedium('google', 'cpc');
    
  } else if (referrerUrl) {
    // a referring domain present
    
    // search engines
    for (let i = 0; i < searchEngines.length; i++) {
      if (referrerTLD.indexOf(searchEngines[i].tld) === 0) {
        return sourceMedium(searchEngines[i].platform, 'organic');
      }
    }
    
    // social referrers
    for (let i = 0; i < socialReferrers.length; i++) {
      if (referrerTLD.indexOf(socialReferrers[i].tld) === 0) {
        return sourceMedium(socialReferrers[i].platform, 'social');
      }
    }
    
    // return the referring domain otherwise
    return sourceMedium(referrerDomain, 'referral');
    
  }

  return sourceMedium('(direct)', '(none)');
}

return;


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "page_location"
              },
              {
                "type": 1,
                "string": "page_referrer"
              }
            ]
          }
        },
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: utm_source=testing&utm_medium=asdf
  code: "const mockData = {\n  urlInput: 'page_location'\n};\n\nmock('getEventData',\
    \ (key) => {\n  if (key === 'page_location') {\n    return 'https://example.com/page?utm_source=testing&utm_medium=asdf';\n\
    \  }\n  if (key === 'page_referrer') {\n    return 'https://www.google.fi/';\n\
    \  }\n});\n  \n\n// Call runCode to run the template's code.\nlet variableResult\
    \ = runCode(mockData);\n\n// Verify that the variable returns a result.\nassertThat(variableResult).isEqualTo('testing\
    \ / asdf');"
- name: google organic
  code: "const mockData = {\n  urlInput: 'page_location',\n  referrerSource: 'page_referrer'\n\
    };\n\nmock('getEventData', (key) => {\n  if (key === 'page_location') {\n    return\
    \ 'https://example.com/page';\n  }\n  if (key === 'page_referrer') {\n    return\
    \ 'https://www.google.fi/';\n  }\n});\n  \n\n// Call runCode to run the template's\
    \ code.\nlet variableResult = runCode(mockData);\n\n// Verify that the variable\
    \ returns a result.\nassertThat(variableResult).isEqualTo('google / organic');"
- name: referral
  code: "const mockData = {\n  urlInput: 'page_location',\n  referrerSource: 'page_referrer'\n\
    };\n\nmock('getEventData', (key) => {\n  if (key === 'page_location') {\n    return\
    \ 'https://example.com/page';\n  }\n  if (key === 'page_referrer') {\n    return\
    \ 'https://testsite.com';\n  }\n});\n  \n\n// Call runCode to run the template's\
    \ code.\nlet variableResult = runCode(mockData);\n\n// Verify that the variable\
    \ returns a result.\nassertThat(variableResult).isEqualTo('testsite.com / referral');"
- name: referral exclusion
  code: "const mockData = {\n  urlInput: 'page_location',\n  referrerSource: 'page_referrer',\n\
    \  referralExclusion: [\n    {domain: 'example.com'}\n  ]\n};\n\nmock('getEventData',\
    \ (key) => {\n  if (key === 'page_location') {\n    return 'https://example.com/page';\n\
    \  }\n  if (key === 'page_referrer') {\n    return 'https://example.com';\n  }\n\
    });\n  \n\n// Call runCode to run the template's code.\nlet variableResult = runCode(mockData);\n\
    \n// Verify that the variable returns a result.\nassertThat(variableResult).isEqualTo(undefined);"
- name: referral exclusion tld
  code: "const mockData = {\n  urlInput: 'page_location',\n  referrerSource: 'page_referrer',\n\
    \  referralExclusion: [\n    {domain: 'example.com'}\n  ]\n};\n\nmock('getEventData',\
    \ (key) => {\n  if (key === 'page_location') {\n    return 'https://sub.example.com/page';\n\
    \  }\n  if (key === 'page_referrer') {\n    return 'https://sub.example.com';\n\
    \  }\n});\n  \n\n// Call runCode to run the template's code.\nlet variableResult\
    \ = runCode(mockData);\n\n// Verify that the variable returns a result.\nassertThat(variableResult).isEqualTo(undefined);"
- name: social referrer
  code: "const mockData = {\n  urlInput: 'page_location',\n  referrerSource: 'page_referrer',\n\
    \  referralExclusion: [\n    {domain: 'example.com'}\n  ]\n};\n\nmock('getEventData',\
    \ (key) => {\n  if (key === 'page_location') {\n    return 'https://example.com/page';\n\
    \  }\n  if (key === 'page_referrer') {\n    return 'https://www.linkedin.com';\n\
    \  }\n});\n  \n\n// Call runCode to run the template's code.\nlet variableResult\
    \ = runCode(mockData);\n\n// Verify that the variable returns a result.\nassertThat(variableResult).isEqualTo('linkedin\
    \ / social');"
- name: (direct) / (none)
  code: "const mockData = {\n  urlInput: 'page_location',\n  referrerSource: 'page_referrer',\n\
    \  referralExclusion: [\n    {domain: 'example.com'}\n  ]\n};\n\nmock('getEventData',\
    \ (key) => {\n  if (key === 'page_location') {\n    return 'https://example.com/page';\n\
    \  }\n  if (key === 'page_referrer') {\n    return undefined;\n  }\n});\n  \n\n\
    // Call runCode to run the template's code.\nlet variableResult = runCode(mockData);\n\
    \n// Verify that the variable returns a result.\nassertThat(variableResult).isEqualTo('(direct)\
    \ / (none)');"
- name: com linkedin android social referrer
  code: "const mockData = {\n  urlInput: 'page_location',\n  referrerSource: 'page_referrer',\n\
    \  referralExclusion: [\n    {domain: 'example.com'}\n  ]\n};\n\nmock('getEventData',\
    \ (key) => {\n  if (key === 'page_location') {\n    return 'https://example.com/page';\n\
    \  }\n  if (key === 'page_referrer') {\n    return 'android-app://com.linkedin.android/';\n\
    \  }\n});\n  \n\n// Call runCode to run the template's code.\nlet variableResult\
    \ = runCode(mockData);\n\n// Verify that the variable returns a result.\nassertThat(variableResult).isEqualTo('linkedin\
    \ / social');"
- name: gclid
  code: "const mockData = {\n  urlInput: 'page_location',\n  referrerSource: 'page_referrer',\n\
    \  referralExclusion: [\n    {domain: 'example.com'}\n  ]\n};\n\nmock('getEventData',\
    \ (key) => {\n  if (key === 'page_location') {\n    return 'https://example.com/page?gclid=12345';\n\
    \  }\n  if (key === 'page_referrer') {\n    return 'https://google.fi';\n  }\n\
    });\n  \n\n// Call runCode to run the template's code.\nlet variableResult = runCode(mockData);\n\
    \n// Verify that the variable returns a result.\nassertThat(variableResult).isEqualTo('google\
    \ / cpc');"
- name: gclsrc
  code: "const mockData = {\n  urlInput: 'page_location',\n  referrerSource: 'page_referrer',\n\
    \  referralExclusion: [\n    {domain: 'example.com'}\n  ]\n};\n\nmock('getEventData',\
    \ (key) => {\n  if (key === 'page_location') {\n    return 'https://example.com/page?gclsrc=aw.ds';\n\
    \  }\n  if (key === 'page_referrer') {\n    return 'https://google.fi';\n  }\n\
    });\n  \n\n// Call runCode to run the template's code.\nlet variableResult = runCode(mockData);\n\
    \n// Verify that the variable returns a result.\nassertThat(variableResult).isEqualTo('google\
    \ / cpc');"


___NOTES___

Created on 4/12/2022, 10:52:30 AM


