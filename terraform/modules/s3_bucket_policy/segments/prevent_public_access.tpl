        {
            "Sid": "DenyPublicReadACL",
            "Effect": "Deny",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": "arn:aws:s3:::${bucket_name}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": [
                        "public-read",
                        "public-read-write",
                        "authenticated-read"
                    ]
                }
            }
        },
        {
            "Sid": "DenyPublicReadGrant",
            "Effect": "Deny",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": "arn:aws:s3:::${bucket_name}/*",
            "Condition": {
                "StringLike": {
                    "s3:x-amz-grant-read": [
                        "*http://acs.amazonaws.com/groups/global/AllUsers*",
                        "*http://acs.amazonaws.com/groups/global/AuthenticatedUsers*"
                    ]
                }
            }
        },
        {
            "Sid": "DenyPublicListACL",
            "Effect": "Deny",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:PutBucketAcl",
            "Resource": "arn:aws:s3:::${bucket_name}",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": [
                        "public-read",
                        "public-read-write",
                        "authenticated-read"
                    ]
                }
            }
        },
        {
            "Sid": "DenyPublicListGrant",
            "Effect": "Deny",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:PutBucketAcl",
            "Resource": "arn:aws:s3:::${bucket_name}",
            "Condition": {
                "StringLike": {
                    "s3:x-amz-grant-read": [
                        "*http://acs.amazonaws.com/groups/global/AllUsers*",
                        "*http://acs.amazonaws.com/groups/global/AuthenticatedUsers*"
                    ]
                }
            }
        }