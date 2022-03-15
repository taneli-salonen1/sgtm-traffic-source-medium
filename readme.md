# Traffic Source / Medium
## A custom variable template for Server-side Google Tag Manager

This template returns a Google Analytics like source / medium value based on the current page's url and the referring page.

The functionality is inspired by the flow chart in GA's documentation: https://support.google.com/analytics/answer/6205762?hl=en#flowchart&zippy=%2Cin-this-article

The template does a best effort to map the referring URL to the correct source / medium value. To do this it looks at this data point, for example:
1. utm_source and utm_medium tags in the URL
2. gclid and gclsrc parameters
3. list of known search engine domains
4. list of known social media domains

The template also includes referral exclusion. If the referral on the page is excluded, the variable will return undefined.