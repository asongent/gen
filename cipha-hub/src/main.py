import os
import requests
from datetime import datetime
from elasticsearch import Elasticsearch, helpers

NEUVECTOR_URL = os.getenv("NEUVECTOR_URL")
NEUVECTOR_USER = os.getenv("NEUVECTOR_USER")
NEUVECTOR_PASS = os.getenv("NEUVECTOR_PASS")

ES_URL = os.getenv("ES_URL")
ES_USER = os.getenv("ES_USER")
ES_PASS = os.getenv("ES_PASS")
INDEX = os.getenv("ES_INDEX", "neuvector-cves")

session = requests.Session()
session.verify = False

def neuvector_login():
    resp = session.post(
        f"{NEUVECTOR_URL}/auth",
        json={"username": NEUVECTOR_USER, "password": NEUVECTOR_PASS}
    )
    resp.raise_for_status()
    token = resp.json().get("token")
    session.headers.update({"X-Auth-Token": token})

def fetch_cves():
    resp = session.get(f"{NEUVECTOR_URL}/scan/workload")
    resp.raise_for_status()
    return resp.json().get("workloads", [])

def format_docs(workloads):
    for workload in workloads:
        for vuln in workload.get("vulnerabilities", []):
            yield {
                "_index": INDEX,
                "_source": {
                    "@timestamp": datetime.utcnow().isoformat(),
                    "vulnerability.id": vuln.get("name"),
                    "vulnerability.severity": vuln.get("severity"),
                    "vulnerability.score.base": vuln.get("score"),
                    "vulnerability.description": vuln.get("description"),

                    "package.name": vuln.get("package_name"),
                    "package.version": vuln.get("package_version"),
                    "package.fixed_version": vuln.get("fixed_version"),

                    "container.image.name": workload.get("image_name"),
                    "container.image.tag": workload.get("image_tag"),
                    "container.name": workload.get("container_name"),

                    "host.name": workload.get("node_name"),
                    "cluster.name": workload.get("cluster_name"),

                    "neuvector.workload_id": workload.get("id"),
                    "neuvector.node": workload.get("node_name")
                }
            }

def main():
    neuvector_login()
    workloads = fetch_cves()

    es = Elasticsearch(ES_URL, basic_auth=(ES_USER, ES_PASS), verify_certs=False)
    helpers.bulk(es, format_docs(workloads))

    print(f"Ingested CVEs at {datetime.utcnow().isoformat()}")

if __name__ == "__main__":
    main()