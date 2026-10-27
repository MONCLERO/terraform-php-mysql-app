# A Multi-Tier PHP and MySQL Architecture on AWS, Built with Terraform

A three-tier web application on AWS, provisioned entirely with Terraform. One apply builds the network, firewalls, servers, and application. One destroy removes it all.

## Overview

A visitor requests a page from the web tier. The web tier forwards the request to the application tier, which runs the PHP code and reads student records from the database tier. The response travels back the same way. Only the web tier is reachable from the internet.

## Architecture

| Tier | Role | Software | Network |
|---|---|---|---|
| Web | Public entry point and reverse proxy | Apache | Public subnet |
| Application | Runs PHP and queries the database | Apache, PHP, PDO MySQL driver | Private subnet |
| Database | Stores the student data | MySQL | Private subnet |

## Network Design

- One VPC, with one public subnet and two private subnets.
- An internet gateway gives the public subnet access to the internet.
- A NAT gateway lets the private tiers download packages without being reachable from outside.
- Separate route tables keep public and private traffic apart.

## Security Model

Each tier has its own security group, and each group trusts only the tier in front of it.

- Web accepts HTTP from anywhere and SSH from the owner's IP only.
- Application accepts traffic on port 8080 from the web tier only.
- Database accepts MySQL traffic from the application tier only.
- SSH to the private tiers is allowed only from the web tier, which acts as the jump host.

## How Terraform Fulfils the Project

- **Infrastructure as code:** the whole environment is described in version-controlled files and can be rebuilt on demand.
- **Dependency handling:** Terraform works out the build order from references between resources. The database is created first, then the application tier, then the web tier.
- **Dynamic values:** private IP addresses are not known until AWS assigns them. Terraform passes them into each server's startup script automatically, so nothing is copied by hand.
- **Automated server setup:** each server configures itself on first boot using a startup script written for its tier.
- **Current machine image:** the Ubuntu image is looked up at apply time rather than hardcoded.
- **Secrets handling:** the database password is a sensitive variable with no default, supplied outside the code.

## Prerequisites

- Terraform installed
- AWS credentials for a non-root IAM user
- An existing EC2 key pair in the target region
- The owner's public IP, for the SSH rule

## Usage

1. Set the key pair name, your public IP, and the database password in a private variables file.
2. Initialize the project.
3. Run a plan and review it.
4. Apply, then wait a few minutes for the startup scripts to finish.
5. Open the web tier's public IP in a browser and request the student page.
6. Destroy the environment when finished.

## Verification

- The student page shows the application server's hostname and the records from the database.
- The private tiers cannot be reached directly from the internet.
- The web tier cannot connect to the database directly.

## Notes

- Destroy the environment after testing to avoid incurring heavy charges/bill.
- The Terraform state file and the variables file hold sensitive values. I kept both out of version control.
- The database password is stored in plain text on the servers. A production build would use a secrets management service.

## Author

Meshach Cyril (MONCLERO)