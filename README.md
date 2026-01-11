# torque-home-assignment
This exercise involves using Quali's Torque platform to launch a basic cloud environment. Torque is our AI-powered tool for provisioning and managing environments, and it integrates with IaC tools like Terraform.

# Prerequisites:
• A Torque account (will be provided)
• Access to a Git repository (e.g., GitHub, GitLab).
• Basic setup with a cloud provider (AWS, Azure, or GCP—use the one you're most
comfortable with, as per the job requirements) - Optional
• Installed tools: Terraform (latest version), Git, and any cloud provider CLI (e.g., AWS
CLI) - Optional
• Familiarity with scripting (e.g., Bash or Python) for any minor automation.


## Repo Structure

```

.
├── modules/
│   └── s3_bucket/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── docs/
│   └── screenshots/
└── README.md

````

---


## Terraform Compatibility Note (Important)

Torque Terraform runners typically support Terraform **up to 1.5.x**.

If your Terraform module requires `>= 1.6.0`, Torque will fail at `terraform init` with:

- `Error: Unsupported Terraform Core version`
- `This configuration does not support Terraform version 1.5.7`

Fix by setting `required_version` to a compatible range, for example in `versions.tf`:

```
terraform {
  required_version = ">= 1.5.0"
}
````

---

## Module: `modules/s3_bucket`

### What it creates

* One S3 bucket with:

  * A name prefix + random suffix
  * Optional versioning
  * Optional force-destroy behavior (depending on implementation)

### Required outputs (must exist in `outputs.tf`)

Torque can only expose outputs if Terraform defines them.

Example `outputs.tf`:

```
output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}

output "region" {
  value = var.region
}
```

---

## Torque Blueprint (High Level)

The Torque blueprint:

* Points to this repo module: `modules/s3_bucket`
* Runs Terraform using the selected agent
* Uses AWS credentials stored in Torque
* Exposes Terraform outputs back to Torque

Key blueprint concepts used:

* `kind: terraform`
* `agent.name: '{{ .inputs.agent }}'`
* `authentication: - '{{ .inputs.aws_credentials }}'`
* Grain outputs + blueprint-level outputs

---

## End-to-End Steps (Start to Finish)

### Step 1 — Verify Agent Connectivity

In Torque:

1. Go to **Settings → Agents**
2. Confirm the agent (example: `aws-agent1`) shows **Connected**

#### Known Issue (Space dropdown empty)

If you see that you can’t select a Space while associating the agent (dropdown is empty):

* Close the associate window
* Edit the agent settings and set:

  * **Default Namespace** (e.g., `default`)
  * **Default Service Account** (e.g., `default`)

---

### Step 2 — Create AWS Credentials in Torque

In Torque:

1. Go to **Settings → Credentials**
2. Create **Space Credentials**
3. Select provider **AWS**
4. Type: **Basic**
5. Enter:

   * AWS Account Number
   * Access Key
   * Secret Key

Recommended credential name: `awscred`

This is required to avoid errors like:

* `No valid credential sources found`
* IMDS failure: `169.254.169.254 connection refused`

---

### Step 3 — Create Blueprint in Torque

1. Go to **Design → Automation Inventory → Blueprints**
2. Click **New Blueprint**
3. Add Terraform asset pointing to:

   * Repo store: your configured repo store in Torque
   * Path: `modules/s3_bucket`
4. Ensure blueprint YAML includes:

   * Agent input
   * Credentials input
   * Grain authentication
   * Grain outputs
   * Blueprint outputs

---

### Step 4 — Launch Blueprint

1. Click **Save Changes**
2. Click **Launch**
3. Provide / confirm values such as:

   * `agent = aws-agent1`
   * `aws_credentials = awscred`
   * `region = us-east-1`
   * `name_prefix = torque-demo`
4. Launch and monitor the run in:

   * **Operate → Operation Hub**

---

### Step 5 — Verify S3 Bucket

In AWS Console:

* **S3 → Buckets**
* Verify bucket exists (example name pattern): `torque-demo-<random>`

---

## Exposing Outputs in Torque (Assignment Requirement)

To expose Terraform outputs in Torque:

### 1) Ensure outputs exist in Terraform

Add outputs in `modules/s3_bucket/outputs.tf`, e.g.:

* `bucket_name`
* `bucket_arn`
* `region`

### 2) Expose outputs from the Terraform grain

In blueprint YAML, add under the grain:

```yaml
grains:
  s3_bucket:
    kind: terraform
    spec:
      outputs:
        - bucket_name
        - bucket_arn
        - region
```

### 3) Map grain outputs to blueprint outputs (recommended)

So they show cleanly at the blueprint/environment level:

```yaml
outputs:
  bucket_name:
    value: '{{ .grains.s3_bucket.outputs.bucket_name }}'
  bucket_arn:
    value: '{{ .grains.s3_bucket.outputs.bucket_arn }}'
  region:
    value: '{{ .grains.s3_bucket.outputs.region }}'
```

---

## Screenshots

This folder in the repo includes all the screenshots:

```
docs/screenshots/
```


### 1) Agent Connected

![Agent Connected](https://github.com/kartiksaini1997/torque-home-assignment/blob/main/docs/01-agent-connected.png)

### 2) Blueprint Designer (Terraform Grain)

![Blueprint Designer](docs/screenshots/02-blueprint-designer-grain.png)

### 3) Torque Credentials (AWS)

![Torque Credentials](docs/screenshots/03-torque-credentials.png)

### 4) Operation Hub Run

![Operation Hub Run](docs/screenshots/04-operation-hub-run.png)

### 5) Torque Outputs (I/O tab)

![Torque Outputs](docs/screenshots/05-torque-outputs.png)

### 6) AWS S3 Bucket Created

![AWS S3 Bucket](docs/screenshots/06-aws-s3-bucket.png)

---

## Common Errors & Fixes

### 1) Launch button greyed out after saving

Error:
`Value '' of field 'grains->s3_bucket->spec->agent->name' resolved to empty value`

Fix:

* Ensure `agent.name` is not empty and references input:

```yaml
agent:
  name: '{{ .inputs.agent }}'
```

---

### 2) Terraform version mismatch

Error:
`Unsupported Terraform Core version ... required_version >= 1.6.0`

Fix:

* Update `versions.tf` to use a supported version constraint, e.g.:

```
terraform {
  required_version = ">= 1.5.0"
}
```

---

### 3) No valid credential sources found

Error:
`No valid credential sources found`
IMDS failures: `169.254.169.254 connection refused`

Fix:

* Create AWS creds in Torque
* Reference them in blueprint via `authentication`:

```yaml
authentication:
  - '{{ .inputs.aws_credentials }}'
```

---

## Notes / Safety

* Do not paste AWS keys in README or screenshots.
* Prefer least-privilege IAM permissions outside of assignment scenarios.

---

