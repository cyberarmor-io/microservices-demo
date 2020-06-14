import sys,json

j = json.load(sys.stdin)
j["executablesList"].append({"mainProcess": "curl","modulesInfo": [{"fullPath": "/usr/bin/curl","name": "curl","mandatory": 1,"signatureMismatchAction": 1,"type": 1}]})
print(json.dumps(j, indent=2))
