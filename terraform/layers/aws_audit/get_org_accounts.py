import boto3
import json
from jq import jq

boto3.setup_default_session(profile_name='your-root-profile')

client = boto3.client('organizations')


def populate_aws_accounts():
    _account_arns = []

    def populate_accounts_from_response(aws_accounts):
        for account in aws_accounts:
            # print(account)
            #_account_arns.append("arn:aws:iam::{}:root".format(account['Id']))
            _account_arns.append(account['Id'])

    accounts_response = client.list_accounts()

    populate_accounts_from_response(accounts_response['Accounts'])

    while accounts_response.get('NextToken') is not None:
        accounts_response = client.list_accounts(
            NextToken=accounts_response['NextToken']
        )
        populate_accounts_from_response(accounts_response['Accounts'])

    return _account_arns


accounts = populate_aws_accounts()
output={"output":"#".join(accounts)}
print(json.dumps(output))
#print(jq(".").transform(json.dumps(accounts)))
