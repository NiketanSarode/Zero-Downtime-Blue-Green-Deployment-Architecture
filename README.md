# AWS High Availability & Blue-Green Deployment

<p align="center">
  <strong>AWS | EC2 | VPC | Application Load Balancer | Apache | Linux</strong>
</p>

<p align="center">
  A hands-on AWS project demonstrating load balancing, health checks, multi-AZ deployment architecture, and Blue-Green deployment with traffic switching and rollback.
</p>

---

## Table of Contents

- [Project Overview](#project-overview)
- [Objectives](#objectives)
- [Architecture Diagram](#architecture-diagram)
- [AWS Services Used](#aws-services-used)
- [Architecture and Resource Configuration](#architecture-and-resource-configuration)
- [Application Environments](#application-environments)
- [Network and Security Configuration](#network-and-security-configuration)
- [Deployment Workflow](#deployment-workflow)
- [Blue-Green Deployment Strategy](#blue-green-deployment-strategy)
- [Health Checks and Traffic Management](#health-checks-and-traffic-management)
- [Validation and Testing](#validation-and-testing)
- [Troubleshooting](#troubleshooting)
- [Security Considerations](#security-considerations)
- [Cost Management and Cleanup](#cost-management-and-cleanup)
- [Limitations and Future Improvements](#limitations-and-future-improvements)
- [Key Learnings](#key-learnings)
- [Author](#author)

---

## Project Overview

This project demonstrates how to deploy and manage two versions of a web application on Amazon Web Services (AWS) using an Application Load Balancer (ALB) and separate target groups.

The architecture consists of two Amazon EC2 instances deployed across two Availability Zones within a custom Virtual Private Cloud (VPC). Each instance hosts an Apache web server serving a different application version.

An internet-facing Application Load Balancer receives HTTP requests and forwards them to the configured target group. Traffic can be switched between the Blue and Green environments to demonstrate deployment validation and rollback.

The project also explores target health monitoring and weighted traffic forwarding as an additional traffic-management technique.

### Project Highlights

- Created a custom AWS VPC with CIDR `10.0.0.0/16`.
- Deployed two EC2 instances across two Availability Zones.
- Hosted two application versions using Apache HTTP Server.
- Configured an internet-facing Application Load Balancer.
- Created separate target groups for Blue and Green environments.
- Configured HTTP health checks on port `80`.
- Implemented Blue-Green traffic switching through the ALB listener.
- Demonstrated rollback by switching traffic back to the previous environment.
- Explored weighted traffic forwarding between target groups.

> **Important:** This is a hands-on learning project. The architecture demonstrates deployment and traffic-management concepts; it does not claim measured production uptime, latency improvements, or zero downtime.

---

## Objectives

The primary objectives of this project are:

1. Understand AWS networking through a custom VPC and public subnets.
2. Deploy EC2 instances across separate Availability Zones.
3. Configure an internet-facing Application Load Balancer.
4. Understand the relationship between listeners, listener rules, and target groups.
5. Configure target health checks and validate target health.
6. Implement Blue-Green deployment through traffic switching.
7. Understand rollback to a previously deployed application version.
8. Apply security group rules to restrict access to application instances.
9. Understand weighted traffic forwarding between target groups.
10. Learn basic AWS resource management and cost-control practices.

---

## Architecture Diagram

The architecture represents the request flow from internet users to the load balancer and then to the selected application environment.

![AWS Blue-Green Deployment Architecture](architecture.png)

**Architecture flow:**

```text
Internet Users
      |
      v
   Internet
      |
      v
Internet Gateway
      |
      v
Application Load Balancer
       HTTP : 80
      |
      v
ALB Listener / Rules
      |
      +-------------------+
      |                   |
      v                   v
   Blue-TG             Green-TG
      |                   |
      v                   v
Blue-Server           Green-Server
EC2 + Apache          EC2 + Apache
Application v1        Application v2
      |                   |
      v                   v
Availability Zone 1   Availability Zone 2
```

### Architecture Notes

- The VPC provides an isolated logical network for the AWS resources.
- The Internet Gateway enables internet connectivity for appropriately configured public resources.
- The Application Load Balancer acts as the public entry point for HTTP requests.
- The listener receives requests on port `80`.
- Each target group represents a separate application environment.
- EC2 instances host the application pages using Apache.
- Health checks allow the ALB to determine whether registered targets are healthy.
- Listener configuration controls which environment receives traffic.

**Diagram file:** Save the architecture image in the repository root using the filename `architecture.png`. If you use another filename or folder, update the image path in this README.

---

## AWS Services Used

| AWS Service / Technology | Purpose |
|---|---|
| Amazon VPC | Provides an isolated virtual network. |
| Public Subnets | Host the application infrastructure with internet routing. |
| Internet Gateway | Enables internet connectivity for the VPC. |
| Amazon EC2 | Runs the Blue and Green application servers. |
| Application Load Balancer | Receives HTTP requests and distributes traffic. |
| Target Groups | Register the application instances and perform health checks. |
| Security Groups | Control inbound and outbound network traffic. |
| Ubuntu Linux | Operating system for the EC2 instances. |
| Apache HTTP Server | Serves the Blue and Green web pages. |

---

## Architecture and Resource Configuration

The following table summarizes the intended project configuration.

| Component | Resource Name | Configuration |
|---|---|---|
| AWS Region | Mumbai | `ap-south-1` |
| VPC | `lb-bluegreen-vpc` | `10.0.0.0/16` |
| Availability Zones | Two AZs | `ap-south-1a` and `ap-south-1b` |
| Public Subnet 1 | Project subnet | `10.0.1.0/24` |
| Public Subnet 2 | Project subnet | `10.0.2.0/24` |
| Blue EC2 | `Blue-Server` | Ubuntu, Apache, Application v1 |
| Green EC2 | `Green-Server` | Ubuntu, Apache, Application v2 |
| Load Balancer | `BlueGreen-ALB` | Internet-facing ALB |
| Blue Target Group | `Blue-TG` | HTTP, port 80 |
| Green Target Group | `Green-TG` | HTTP, port 80 |
| ALB Security Group | `ALB-SG` | HTTP ingress from the internet |
| EC2 Security Group | `EC2-SG` | HTTP ingress from `ALB-SG` |

The EC2 instance type used in the project was `t3.micro`.

> Resource names are included to document the project configuration. The AWS resources used for the hands-on demonstration were subsequently cleaned up, so this README does not represent an actively running deployment.

---

## Application Environments

The project contains two application environments.

### 1. Blue Environment

**Instance:** `Blue-Server`  
**Target Group:** `Blue-TG`  
**Web Server:** Apache HTTP Server  
**Application Version:** Version 1

The Blue environment represents the currently selected or previous application version.

Example web page:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Blue Environment</title>
</head>
<body>
    <h1>BLUE ENVIRONMENT</h1>
    <p>Application Version 1</p>
</body>
</html>
```

### 2. Green Environment

**Instance:** `Green-Server`  
**Target Group:** `Green-TG`  
**Web Server:** Apache HTTP Server  
**Application Version:** Version 2

The Green environment represents the alternate application version used to demonstrate a deployment and traffic switch.

Example web page:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Green Environment</title>
</head>
<body>
    <h1>GREEN ENVIRONMENT</h1>
    <p>Application Version 2</p>
</body>
</html>
```

These pages make it easy to identify which application environment is responding to a request.

---

## Network and Security Configuration

### VPC Configuration

A custom VPC named `lb-bluegreen-vpc` was configured with the CIDR block:

```text
10.0.0.0/16
```

Two public subnets were used across separate Availability Zones.

| Subnet | CIDR | Availability Zone |
|---|---|---|
| Public Subnet 1 | `10.0.1.0/24` | `ap-south-1a` |
| Public Subnet 2 | `10.0.2.0/24` | `ap-south-1b` |

An Internet Gateway was attached to the VPC, and internet routing was configured for the public subnets.

**Note:** The demonstration uses public subnets. A production architecture may place application instances in private subnets and use NAT or other appropriate connectivity mechanisms when required.

### Security Group Configuration

#### ALB-SG

Controls access to the public load balancer.

| Direction | Protocol | Port | Source / Destination |
|---|---|---|---|
| Inbound | HTTP | 80 | `0.0.0.0/0` |
| Outbound | As configured | All | Default outbound allowance |

The inbound rule permits clients on the internet to send HTTP requests to the load balancer.

#### EC2-SG

Controls access to the application instances.

| Direction | Protocol | Port | Source / Destination |
|---|---|---|---|
| Inbound | HTTP | 80 | `ALB-SG` |
| Outbound | As configured | All | Default outbound allowance |

The EC2 security group accepts HTTP traffic from the load balancer's security group rather than allowing direct HTTP ingress from every internet address.

This establishes the intended request path:

```text
Internet
   |
   v
ALB-SG
   |
   v
EC2-SG
   |
   v
Apache Web Server
```

---

## Deployment Workflow

The project was configured using the AWS Management Console.

### Step 1: Create the VPC

1. Open the Amazon VPC console.
2. Create a VPC named `lb-bluegreen-vpc`.
3. Set the IPv4 CIDR block to `10.0.0.0/16`.
4. Create two public subnets in separate Availability Zones.
5. Create and attach an Internet Gateway.
6. Configure the public route table to route internet-bound traffic through the Internet Gateway.
7. Associate the route table with the public subnets.

### Step 2: Create Security Groups

Create two security groups:

- `ALB-SG` — allows inbound HTTP traffic on port `80`.
- `EC2-SG` — allows inbound HTTP traffic on port `80` from `ALB-SG`.

Apply the appropriate security groups when creating the load balancer and EC2 instances.

### Step 3: Launch the Blue EC2 Instance

1. Open the Amazon EC2 console.
2. Launch an Ubuntu 24.04 LTS instance.
3. Select the `t3.micro` instance type.
4. Place the instance in Public Subnet 1.
5. Configure its security group to use `EC2-SG`.
6. Install and start Apache using EC2 User Data.
7. Serve a page identifying the application as Blue, Version 1.

Example User Data:

```bash
#!/bin/bash

apt-get update -y
apt-get install -y apache2

systemctl enable apache2
systemctl start apache2

cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Blue Environment</title>
</head>
<body>
    <h1>BLUE ENVIRONMENT</h1>
    <p>Application Version 1</p>
</body>
</html>
EOF
```

### Step 4: Launch the Green EC2 Instance

1. Launch a second Ubuntu EC2 instance.
2. Select the `t3.micro` instance type.
3. Place the instance in Public Subnet 2.
4. Configure its security group to use `EC2-SG`.
5. Install and start Apache.
6. Serve a page identifying the application as Green, Version 2.

Example User Data:

```bash
#!/bin/bash

apt-get update -y
apt-get install -y apache2

systemctl enable apache2
systemctl start apache2

cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Green Environment</title>
</head>
<body>
    <h1>GREEN ENVIRONMENT</h1>
    <p>Application Version 2</p>
</body>
</html>
EOF
```

> These scripts are reference examples of the server configuration. If you recreate the project, verify that the instances have the necessary package-repository connectivity and that Apache starts successfully.

### Step 5: Create the Target Groups

Create two target groups.

**Blue-TG**

- Target type: Instances
- Protocol: HTTP
- Port: `80`
- Health check path: `/`
- Registered target: `Blue-Server`

**Green-TG**

- Target type: Instances
- Protocol: HTTP
- Port: `80`
- Health check path: `/`
- Registered target: `Green-Server`

Wait for the registered targets to become healthy before validating the load balancer.

### Step 6: Create the Application Load Balancer

1. Open the EC2 console's Load Balancers section.
2. Create an Application Load Balancer named `BlueGreen-ALB`.
3. Select the internet-facing scheme.
4. Select IPv4.
5. Choose the custom VPC.
6. Map the ALB to both public subnets.
7. Attach `ALB-SG`.
8. Create an HTTP listener on port `80`.
9. Configure the default action to forward requests to `Blue-TG`.

Once the ALB is active and its target is healthy, copy its DNS name for testing.

---

## Blue-Green Deployment Strategy

Blue-Green deployment maintains two separate application environments so that traffic can be directed to the selected version.

In this project:

- **Blue** represents Application Version 1.
- **Green** represents Application Version 2.
- The ALB provides a consistent public entry point.
- The listener determines the target group receiving traffic.

### Deployment Flow

```text
Client Request
      |
      v
BlueGreen-ALB
      |
      v
HTTP Listener : 80
      |
      v
Blue-TG
      |
      v
Blue-Server (v1)
```

After validating the Green environment, change the listener's forwarding action to `Green-TG`.

```text
Client Request
      |
      v
BlueGreen-ALB
      |
      v
HTTP Listener : 80
      |
      v
Green-TG
      |
      v
Green-Server (v2)
```

### Switch from Blue to Green

1. Open the EC2 console.
2. Select `BlueGreen-ALB`.
3. Open the Listeners and Rules section.
4. Edit the HTTP listener's default forwarding action.
5. Change the target group from `Blue-TG` to `Green-TG`.
6. Save the listener configuration.
7. Open the ALB DNS name in a browser and verify that the Green page is returned.

### Roll Back from Green to Blue

If the new version fails validation:

1. Open the ALB listener configuration.
2. Change the forwarding action from `Green-TG` back to `Blue-TG`.
3. Save the configuration.
4. Test the ALB DNS name again.
5. Verify that the Blue page is returned.

### Why Use Blue-Green Deployment?

- Separates the new application version from the existing version.
- Allows validation of the alternate environment before switching traffic.
- Makes rollback straightforward when the previous environment remains healthy.
- Keeps the public ALB endpoint unchanged during a target-group switch.

**Important:** Changing the listener's target group does not guarantee zero downtime. Existing connections, health status, application readiness, and listener propagation can affect the transition.

---

## Health Checks and Traffic Management

### Target Health Checks

The target groups use HTTP health checks.

| Setting | Value |
|---|---|
| Protocol | HTTP |
| Port | Traffic port (`80`) |
| Path | `/` |
| Expected result | Successful HTTP response |

The ALB periodically sends health-check requests to registered targets. A target that satisfies the configured health-check criteria is reported as healthy.

If a target is unhealthy, investigate the Apache service, application response, security group rules, and target-group health-check settings.

### Weighted Traffic Forwarding

An ALB listener can also forward traffic to multiple target groups using configured weights.

For example, a hypothetical `50:50` configuration is:

| Target Group | Weight |
|---|---:|
| Blue-TG | 50 |
| Green-TG | 50 |

This configuration is useful for demonstrating controlled traffic distribution between application versions.

**Note:** Weighted forwarding must be configured explicitly in the listener action. A normal default action forwarding to a single target group does not create a 50:50 split.

Weights express the relative distribution of new routing decisions; they do not guarantee that every pair of requests will be split evenly. Actual observations can vary with request volume, connection reuse, and other traffic characteristics.

For a straightforward Blue-Green deployment, use one active target group at a time. Use weighted forwarding when deliberately testing traffic distribution or a gradual rollout.

---

## Validation and Testing

The following checks can be performed when recreating the infrastructure.

| Test | Procedure | Expected Result |
|---|---|---|
| Blue server validation | Open the Blue instance's test page in an appropriately permitted environment. | Blue page displays Version 1. |
| Green server validation | Open the Green instance's test page in an appropriately permitted environment. | Green page displays Version 2. |
| Target health | Inspect the registered targets in each target group. | Both application instances report healthy when correctly configured. |
| ALB connectivity | Open the ALB DNS name over HTTP. | The page from the selected target group is displayed. |
| Blue-to-Green switch | Change the listener action to `Green-TG`. | Subsequent requests are routed according to the updated listener configuration. |
| Rollback | Change the listener action back to `Blue-TG`. | Subsequent requests are routed according to the restored configuration. |
| Weighted routing | Configure both target groups in one weighted forwarding action. | Requests are distributed according to the configured weights over time. |

### Evidence to Capture

For a portfolio-ready repository, include screenshots of:

1. VPC and subnet configuration.
2. EC2 instances and their Availability Zones.
3. Blue and Green target groups showing healthy targets.
4. ALB listener configuration.
5. Blue application page.
6. Green application page.
7. Successful Blue-to-Green switch.
8. Successful rollback to Blue.
9. Weighted forwarding configuration, if implemented.

Store screenshots in a folder such as `screenshots/` and link them from this README.

Example:

```markdown
![Target Group Health](screenshots/target-group-health.png)
```

Only add screenshots that show configurations or results you actually observed.

---

## Troubleshooting

### 1. Target Group Shows Unhealthy

**Possible causes:**

- Apache is not installed or running.
- The application page is not returning a successful HTTP response.
- The EC2 security group does not allow traffic from `ALB-SG`.
- The health-check path is incorrect.
- The application server has not finished starting.

**Checks on Ubuntu:**

```bash
sudo systemctl status apache2
```

```bash
curl -I http://localhost/
```

```bash
sudo systemctl restart apache2
```

Review the target group's health-check reason and verify the EC2 security group rules.

### 2. ALB DNS Name Does Not Open

Check that:

- The load balancer is active.
- The ALB is mapped to the intended subnets.
- The ALB security group permits inbound HTTP on port `80`.
- The listener is configured on port `80`.
- The selected target group has a healthy registered target.
- The target instance's security group permits HTTP from `ALB-SG`.

### 3. Green Environment Is Not Displayed

Check that:

- `Green-Server` is running.
- Apache serves the Green page.
- `Green-TG` contains the correct instance.
- The Green target is healthy.
- The ALB listener forwards requests to `Green-TG`.

### 4. `/green` Path Returns 404

An ALB path-based rule forwards a request to a target group but does not automatically remove the path from the HTTP request.

For example, a request to `/green` can reach Apache as `/green`. If the web server does not have a matching resource or rewrite rule, it may return `404 Not Found`.

For this project, switching the listener's default target group is the simpler Blue-Green deployment approach.

---

## Security Considerations

The project uses security groups to restrict access to the application infrastructure.

Recommended improvements for a production-oriented implementation include:

- Place application instances in private subnets when public IP access is unnecessary.
- Permit application HTTP traffic from the ALB security group only.
- Restrict administrative access using an approved, least-privilege method.
- Avoid exposing SSH to `0.0.0.0/0`.
- Use HTTPS with an appropriate TLS certificate for public applications.
- Use IAM roles with least-privilege permissions when instances require AWS API access.
- Avoid embedding credentials or secrets in User Data or source control.
- Review CloudWatch logs and monitoring requirements before production use.

This project demonstrates core networking and traffic-management concepts; it is not a complete production security baseline.

---

## Cost Management and Cleanup

AWS resources can incur charges even when the application is not actively receiving requests.

Potential cost-bearing resources include:

- EC2 instances.
- Application Load Balancers.
- Public IPv4 addresses.
- NAT Gateways, if added.
- EBS volumes.
- Data transfer.

### Cleanup Checklist

When finishing a recreated deployment:

1. Delete the Application Load Balancer.
2. Delete the Blue and Green target groups.
3. Terminate the Blue and Green EC2 instances.
4. Delete project-specific security groups after checking for dependencies.
5. Detach and delete the Internet Gateway when it is no longer needed.
6. Delete the custom VPC and its remaining resources.
7. Check for unattached EBS volumes and unused Elastic IP addresses.
8. Review AWS Billing and Cost Management for remaining resources.

> The hands-on resources from this demonstration were cleaned up. Recreating the project will provision new resources and may incur AWS charges.

---

## Limitations and Future Improvements

This project focuses on manually configuring the AWS architecture and demonstrating traffic switching.

Possible next steps:

- **Infrastructure as Code:** Provision the VPC, EC2 instances, target groups, and ALB using Terraform or AWS CloudFormation.
- **CI/CD:** Automate application deployment using Jenkins or AWS CodePipeline.
- **HTTPS:** Configure TLS termination with AWS Certificate Manager.
- **Private Networking:** Move application instances into private subnets.
- **Monitoring:** Add Amazon CloudWatch metrics, alarms, and logs.
- **Deployment Automation:** Automate Blue-Green switching and rollback.
- **Automated Validation:** Run health checks and smoke tests before changing production traffic.
- **Application Scaling:** Introduce Auto Scaling Groups to manage instance capacity.
- **Observability:** Track request counts, target response times, HTTP errors, and unhealthy hosts.

These are potential extensions, not features claimed as already implemented.

---

## Key Learnings

Through this project, I explored:

- AWS VPC and public subnet configuration.
- Internet Gateway and routing concepts.
- EC2 instance deployment on Ubuntu Linux.
- Apache web server installation and configuration.
- Application Load Balancer listeners and target groups.
- Target-group health checks.
- Security group-based traffic restrictions.
- Blue-Green deployment and rollback workflows.
- Weighted traffic forwarding.
- AWS resource cleanup and cost awareness.

---

## Author

**Project:** AWS High Availability & Blue-Green Deployment

**Focus Areas:** Cloud Computing, AWS Networking, Load Balancing, Deployment Strategies, Linux, and DevOps Fundamentals.

---

## Disclaimer

This repository documents a learning project built to understand AWS load balancing and Blue-Green deployment concepts. It is not a production deployment template. Validate security, availability, and cost requirements before adapting the architecture for real workloads.
