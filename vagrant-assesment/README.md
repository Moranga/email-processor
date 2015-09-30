

documentation
====

This folder contains simple vagrant + puppet structure to:

- provision server
- deploy application (and release a new version based on commits on github)
- add monitoring (datadoghq.com)
- assign EIP, if defined on environments variabls
- log metrics of emails processed into aws cloudwatch (this is done in the app level) - 
- create an SNS ARN for notifications - it requires manual step to connect the ARN to the cloudwatch alert.

Configuration
====

The following environment variables can be passed to vagrant:

	export AWS_ACCESS_KEY_ID=jiefj9309d3kd3j9
	export AWS_SECRET_ACCESS_KEY=j9fjifjifjifj4343
	export AWS_DEFAULT_REGION=eu-west-1
	export EMAILPROCESSOR_BING_TO_S3_PREFIX=emailsprocessed
	export EMAILPROCESSOR_BING_TO_S3_BUCKET=my_s3_bucket
	export EMAILPROCESSOR_USERNAME=test
	export EMAILPROCESSOR_PORT=2525
	export EMAILPROCESSOR_ADDRESS=
	export SNS_NAME=it_email_processor
	export SNS_DEFAULT_MAIL=p@example.com
	export AWS_EIP=5.9.11.73



Just re-deploy the app
====

You can redeploy the app, by running:

        cd /opt/email-processor/vagrant-assesment/
        bash apply_puppet.sh


Missing
====

- Better monitoring (datadog not satisfactory)
- Better SNS integration
- Plug of EIP not activated
- email address where the emails should be directed: I made no DNS changes and MX related, so I don't have how to provide it. you will need to change the MX records to the ip provided at the end of vagrant run to compute the email address.

