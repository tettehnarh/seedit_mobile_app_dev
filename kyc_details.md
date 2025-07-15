# KYC Form Structure

# KYC Form Structure

## Category of Account
- **Account Category**: `{{ account_category }}`


## Section 1: Personal Information
- **Status**: `{{ personal_info_status }}`
- **First Name**: `{{ first_name }}`
- **Last Name**: `{{ last_name }}`
- **Gender**: `{{ gender }}`
- **Date of Birth**: `{{ date_of_birth }}`
- **Nationality**: `{{ nationality }}`
- **Phone Number**: `{{ phone_number }}`
- **Address**: `{{ address }}`
- **City**: `{{ city }}`
- **GPS Code**: `{{ gps_code }}`

## Section 2: Next of Kin
- **Status**: `{{ next_of_kin_status }}`
- **First Name**: `{{ kin_first_name }}`
- **Last Name**: `{{ kin_last_name }}`
- **Relationship**: `{{ kin_relationship }}`
- **Phone Number**: `{{ kin_phone_number }}`
- **Email**: `{{ kin_email }}`

## Section 3: Professional & Financial Information
- **Status**: `{{ professional_info_status }}`
- **Profession**: `{{ profession }}`
- **Employment Status**: `{{ employment_status }}`
- **Institution Name**: `{{ institution_name }}`
- **Annual Income**: `{{ annual_income }}`
- **Source of Income**: `{{ source_of_income }}`

## Section 4: ID Information
- **Status**: `{{ id_info_status }}`
- **ID Type**: `{{ id_type }}`
- **ID Number**: `{{ id_number }}`
- **Issue Date**: `{{ id_issue_date }}`
- **Expiry Date**: `{{ id_expiry_date }}`
- **ID Document Front**: `{{ id_document_front }}`
- **ID Document Back**: `{{ id_document_back }}`
- **Selfie Document**: `{{ selfie_document }}`

## Section 4: In trust For
- **Status**: `{{ id_info_status }}`
- **ID Type**: `{{ id_type }}`
- **ID Number**: `{{ id_number }}`
- **Issue Date**: `{{ id_issue_date }}`
- **Expiry Date**: `{{ id_expiry_date }}`
- **ID Document Front**: `{{ id_document_front }}`
- **ID Document Back**: `{{ id_document_back }}`
- **Selfie Document**: `{{ selfie_document }}`

## Field Choices Reference

### Category of Account Choices
- Individual
- In-Trust-For
    #### In-Trust-For Details
    - First Name
    - Last Name
    - Gender
    - Date of Birth
    - Nationality
    - Phone Number
    - Address
    - City
    - ID Type
    - ID Number
    - Issue Date
    - Expiry Date
    - ID Document Front
    - ID Document Back


### Section Status Choices
- Not Started
- In Progress
- Completed
- Verified
- Rejected

### Gender Choices
- Male
- Female


### Relationship Choices
- Parent
- Spouse
- Sibling
- Child
- Other Relative
- Friend
- Other

### Employment Status Choices
- Employed
- Self-Employed
- Unemployed
- Student
- Retired
- Other

### Source of Income Choices
- Salary
- Business
- Investments
- Pension
- Allowance
- Other

### ID Type Choices
- Passport
- National ID
- Driver's License
