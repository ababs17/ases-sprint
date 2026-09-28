CLINICASSIST

1. Data Flow 
-Entities: Clinician, Patient, Partner, Doctor,Users
-Processes: Fetch_record, search_guidelines, draft_report, send_referral
-Data store: User Memory, EHR, Clinician Data
-Data flow: User-2-model, Model-2-database

2. PDF file :laB-2
a. User- Untrusted
b. Internal guidelines - Trusted
c. Hosted LLM - Semi- Trusted

3. STRIDE
Letter	Threat	                      Question	                                            Example
S	  Spoofing	                Can someone pretend to be someone they're not?	        Fake clinician login
T	  Tampering	                Can someone modify data in transit or at rest?	        Change patient record
R	  Repudiation	                Can someone deny they did something?	                "I didn't send that referral"
I	  Information Disclosure	Can someone access data they shouldn't?  	             Read patient data
D	  Denial of Service       	Can someone make the system unavailable?	            Crash the tablet app
E	  Elevation of Privilege	    Can someone gain higher permissions?	                User becomes admin


Elements :
a. Clinicial:
SPOOFING (S):
  Threat: Another clinician uses same shared tablet, impersonates first clinician
  Impact: Wrong clinician's name on documentation
  
TAMPERING (T):
  Threat: Clinician modifies AI-generated draft before sending
  Impact: Reports contain false information
  (This is actually acceptable - clinician reviews output)
  
REPUDIATION (R):
  Threat: Clinician claims "I didn't write that draft"
  Impact: Accountability lost
  
INFORMATION DISCLOSURE (I):
  Threat: Patient data visible on shared tablet screen
  Impact: Another clinician sees patient info they shouldn't
  
DENIAL OF SERVICE (D):
  Threat: Clinician abuses the system, makes it slow for others
  Impact: Other clinicians can't use the tablet
  
ELEVATION OF PRIVILEGE (E):
  Threat: Clinician uses admin tablet instead of regular one
  Impact: Clinician has more permissions than allowed


b. Hosted LLM:
SPOOFING (S):
  Threat: Attacker intercepts API call, responds as fake LLM
  Impact: We get attacker-controlled output, think it's from LLM
  Mitigation: Use TLS, verify certificates
  
TAMPERING (T):
  Threat: LLM provider modifies responses
  Impact: Incorrect clinical information in report
  Mitigation: Validate responses, keep local copies
  
REPUDIATION (R):
  Threat: LLM provider claims they didn't process our data
  Impact: No accountability for data handling
  Mitigation: Audit logs
  
INFORMATION DISCLOSURE (I):
  Threat: LLM provider sees patient data we send to LLM
  Impact: Privacy violation, GDPR violation
  Mitigation: Don't send sensitive data to LLM, use local model instead
  
DENIAL OF SERVICE (D):
  Threat: LLM API is down or overloaded
  Impact: ClinicAssist can't generate reports
  Mitigation: Fallback to template, cache responses
  
ELEVATION OF PRIVILEGE (E):
  Threat: Attacker compromises LLM API account
  Impact: Attacker can modify what LLM returns
  Mitigation: Separate API key, rotate regularly, monitor usage


c.Data Guidelines
SPOOFING (S):
  Threat: Fake guidelines added to database
  Impact: Clinicians follow wrong protocols
  Mitigation: Only approved editors, audit trail
  
TAMPERING (T):
  Threat: Guidelines modified by staff member
  Impact: Outdated or incorrect guidelines used
  Mitigation: Version control, approval process
  
REPUDIATION (R):
  Threat: Staff denies they modified guidelines
  Impact: Can't trace who introduced error
  Mitigation: Audit logs with user attribution
  
INFORMATION DISCLOSURE (I):
  Threat: Guidelines contain patient info from prior use
  Impact: Patient privacy violated
  Mitigation: Sanitize before storing, access control
  
DENIAL OF SERVICE (D):
  Threat: Database is corrupted or deleted
  Impact: No guidelines available, system unusable
  Mitigation: Backups, redundancy, restore procedure
  
ELEVATION OF PRIVILEGE (E):
  Threat: Regular staff can edit guidelines
  Impact: Anyone can change clinical protocols
  Mitigation: Editor role restricted, approval required







4. Agentic Questions
a. Provenance: Threat: We would not be able to trace an action to its cause so blames and failures can not be defined and debugged appropriately.
Eg. LLM decides to call any tool but prompts become too long to know why and who did, An ambitious input attribution when distinguishing command from users aor inference by AI
b. Reversibility: Threat: Actions that can be can not be reverted. Eg.Sending of wrong referrals, EHR that has some mistakes and used for a patient diagnosis(Cascade of irreversible events).
c.Blast radius: Threats: LLM calling any tool within the architecture without limits can cause it to deleted system database due to AI inference or malicious prompts by user, Privacy violation 
d.Rate: Threats: LLM actions that can be made without user supervision and can results in drifts,such as wrong user referrals or automated report draftings which when not supervised can lead to mis or wrong diagnosis.
e. Composition: Threats: Pairs of tools that used together poses a threat. Eg. fetching the data and drafting the report + the LLM queries can lead to reporting false information which will intend lead to wrong referrals.



5.                  Likelihood of Exploitation
                    Low          High
              ┌─────────────┬──────────────┐
              │   Low       │   Medium     │
Impact        │   Priority  │   Priority   │
              ├─────────────┼──────────────┤
              │   Medium    │   HIGH       │
              │   Priority  │   Priority   │
              └─────────────┴──────────────┘


Threat: "Prompt injection causes wrong patient record fetch"
Impact: CRITICAL (wrong patient's data used, clinical error)
Likelihood: MEDIUM (requires attacker to control user input)
Priority: HIGH (top 5)
Owner: Security team

Threat: "Clinician modifies report before sending"
Impact: MEDIUM (report could be incorrect, but clinician is responsible)
Likelihood: HIGH (clinician has direct access)
Priority: MEDIUM (need audit trail, not critical)
Owner: Product team

Threat: "LLM API is compromised"
Impact: CRITICAL (all outputs could be malicious)
Likelihood: LOW (LLM provider is trusted)
Priority: MEDIUM (can't prevent, but must detect)
Owner: Infra team

Threat: "Partner facility sends corrupted OCR data"
Impact: MEDIUM (data quality issue, but clinician reviews)
Likelihood: HIGH (OCR is imperfect)
Priority: MEDIUM (need validation)
Owner: Data quality team

Threat: "Shared tablet used by multiple clinicians"
Impact: CRITICAL (wrong clinician performs actions)
Likelihood: HIGH (tablets are shared in clinic)
Priority: HIGH (top 5)
Owner: Deployment team


6. Mitigation
Threat: "Clinician modifies report before sending"
Status: ACCEPTED

Reason: 
  - Clinician review and modification is REQUIRED (not a bug)
  - Clinician is accountable for final document
  - Audit trail captures modifications
  - Cannot prevent without removing clinician agency
  
Residual Risk:
  - Reports contain modifications not tracked to LLM output
  - Clinician bears responsibility

Monitoring:
  - Audit log review in quality audits
  - Spot-check clinician reports quarterly

Threat: "LLM API is down/unavailable"
Status: ACCEPTED

Reason:
  - LLM provider has 99.9% SLA
  - Temporary unavailability acceptable
  - Clinician can fall back to manual documentation
  - Cost of mitigation (local LLM) exceeds benefit
  
Residual Risk:
  - During outage, system unavailable
  - Clinician must do extra work

Monitoring:
  - Monitor API availability metrics
  - Alert on repeated outages
  - Re-evaluate quarterly

