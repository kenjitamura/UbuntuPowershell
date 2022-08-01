### Description  
This is a script that extends the filtering and sorting capabilities of a job search performed with [The Utah State Job Search Board](https://jobs.utah.gov).  
It currently outputs a file to the current directory called "test.md" which contains an expandable HTML table of job postings.  

### Reasoning  
The Utah job search board as far as I could tell did not expose the ability to limit results by their age or filter the results.  This script was written to filter or sort results based on properties that exist in the results not being utilized by the sites own search engine.  

### Methodology  
I captured a session that included logging in and searching and identified how to format the JSON requests as well as which URL's need to be navigated to in advance to build the cookie jar needed to perform the search.  

### Requirements  
A job search account with the Utah state job search board is necessary as it is used to authenticate to retrieve the OAUTH2 SSO cookie.  

### Limitations  
This script currently has limitations that need fixing at a later date:  
1. Each invocation of the script requires entering credentials as the cookie jar is not being saved to file.  
2. Clicking the "Job Link" to view the job description will require authenticating to the site with your web browser if it doesn't currently have a valid SSO cookie.  This is because the link being used does not currently pass the cookies into the browser session.  
3. The "Job Link" is currently just a URL to the actual job posting on the site.  The search results actually pull in an oracle clobber link for the job description and that could potentially be utilized to update the listing with a description by resolving that clobber link which would use less bandwidth as only the description is retrieved.  
4. This hasn't been tested with Powershell Desktop and if I had to guess the ConvertTo-Json Depths would need to be modified to work with Powershell Desktop.  

### Example Output  
This search was performed with the following parameters:  
Enter keyword search: ("help desk" or "service desk")  
Enter zip: 84102  
Enter radius: 10  
Enter Cut Off Age in Days for Listing: 4  
Include Temp Jobs? Y/N: n  
<table><tr><td>
<details>
<summary style="font-size:16px">IT Service Desk Technician - Level 3</summary>

<table> <tr><td>Link:</td><td><a href="https://jobs.utah.gov/jsp/utjobs/single-job?j=7924463">Job Link</a></td></tr> <tr><td>City:</td><td>SALT LAKE CITY</td></tr> <tr><td>OpenDate:</td><td>2022-08-01</td></tr> <tr><td>Employer:</td><td>Inline Plastics</td></tr> <tr><td>Industry:</td><td>Computer</td></tr> <tr><td>Distance:</td><td>3</td></tr> <tr><td>CloseDate:</td><td></td></tr> <tr><td>Remote:</td><td>N</td></tr> </table>
</details>
<tr><td> <tr><td>
<details>
<summary style="font-size:16px">Tier 1 Service Desk Analyst with Secret </summary>

<table> <tr><td>Link:</td><td><a href="https://jobs.utah.gov/jsp/utjobs/single-job?j=7920953">Job Link</a></td></tr> <tr><td>City:</td><td>SALT LAKE CITY</td></tr> <tr><td>OpenDate:</td><td>2022-07-31</td></tr> <tr><td>Employer:</td><td>Deloitte</td></tr> <tr><td>Industry:</td><td>Computer</td></tr> <tr><td>Distance:</td><td>3</td></tr> <tr><td>CloseDate:</td><td></td></tr> <tr><td>Remote:</td><td>N</td></tr> </table>
</details>
<tr><td> <tr><td>
<details>
<summary style="font-size:16px">Telecommunications Specialist</summary>

<table> <tr><td>Link:</td><td><a href="https://jobs.utah.gov/jsp/utjobs/single-job?j=7921353">Job Link</a></td></tr> <tr><td>City:</td><td>SALT LAKE CITY</td></tr> <tr><td>OpenDate:</td><td>2022-07-31</td></tr> <tr><td>Employer:</td><td>Utah Retirement Systems</td></tr> <tr><td>Industry:</td><td>Computer</td></tr> <tr><td>Distance:</td><td>3</td></tr> <tr><td>CloseDate:</td><td></td></tr> <tr><td>Remote:</td><td>N</td></tr> </table>
</details>
<tr><td> <tr><td>
<details>
<summary style="font-size:16px">Information Technology</summary>

<table> <tr><td>Link:</td><td><a href="https://jobs.utah.gov/jsp/utjobs/single-job?j=7916233">Job Link</a></td></tr> <tr><td>City:</td><td>SALT LAKE CITY</td></tr> <tr><td>OpenDate:</td><td>2022-07-30</td></tr> <tr><td>Employer:</td><td>BHI Energy</td></tr> <tr><td>Industry:</td><td>Management</td></tr> <tr><td>Distance:</td><td>3</td></tr> <tr><td>CloseDate:</td><td></td></tr> <tr><td>Remote:</td><td>N</td></tr> </table>
</details>
<tr><td> <tr><td>
<details>
<summary style="font-size:16px">Field Technician C</summary>

<table> <tr><td>Link:</td><td><a href="https://jobs.utah.gov/jsp/utjobs/single-job?j=7911265">Job Link</a></td></tr> <tr><td>City:</td><td>SALT LAKE CITY</td></tr> <tr><td>OpenDate:</td><td>2022-07-29</td></tr> <tr><td>Employer:</td><td>L3Harris</td></tr> <tr><td>Industry:</td><td>Sciences</td></tr> <tr><td>Distance:</td><td>3</td></tr> <tr><td>CloseDate:</td><td></td></tr> <tr><td>Remote:</td><td>N</td></tr> </table>
</details>
<tr><td> <tr><td>
<details>
<summary style="font-size:16px">Specialist II,Service Desk Support Techn</summary>

<table> <tr><td>Link:</td><td><a href="https://jobs.utah.gov/jsp/utjobs/single-job?j=7912841">Job Link</a></td></tr> <tr><td>City:</td><td>SALT LAKE CITY</td></tr> <tr><td>OpenDate:</td><td>2022-07-29</td></tr> <tr><td>Employer:</td><td>SitusAMC</td></tr> <tr><td>Industry:</td><td>Computer</td></tr> <tr><td>Distance:</td><td>3</td></tr> <tr><td>CloseDate:</td><td></td></tr> <tr><td>Remote:</td><td>N</td></tr> </table>
</details>
<tr><td> <tr><td>
<details>
<summary style="font-size:16px">Content Strategy Manager</summary>

<table> <tr><td>Link:</td><td><a href="https://jobs.utah.gov/jsp/utjobs/single-job?j=7912609">Job Link</a></td></tr> <tr><td>City:</td><td>SALT LAKE CITY</td></tr> <tr><td>OpenDate:</td><td>2022-07-29</td></tr> <tr><td>Employer:</td><td>Meta</td></tr> <tr><td>Industry:</td><td>Management</td></tr> <tr><td>Distance:</td><td>3</td></tr> <tr><td>CloseDate:</td><td></td></tr> <tr><td>Remote:</td><td>N</td></tr> </table>
</details>
<tr><td> <tr><td>
<details>
<summary style="font-size:16px">Deloitte Risk & Financial Advisory Solut</summary>

<table> <tr><td>Link:</td><td><a href="https://jobs.utah.gov/jsp/utjobs/single-job?j=7910527">Job Link</a></td></tr> <tr><td>City:</td><td>SALT LAKE CITY</td></tr> <tr><td>OpenDate:</td><td>2022-07-29</td></tr> <tr><td>Employer:</td><td>Deloitte</td></tr> <tr><td>Industry:</td><td>Business/Finance</td></tr> <tr><td>Distance:</td><td>3</td></tr> <tr><td>CloseDate:</td><td></td></tr> <tr><td>Remote:</td><td>N</td></tr> </table>
</details>
<tr><td> <tr><td>
<details>
<summary style="font-size:16px">Corporate Solutions Engineer</summary>

<table> <tr><td>Link:</td><td><a href="https://jobs.utah.gov/jsp/utjobs/single-job?j=7907431">Job Link</a></td></tr> <tr><td>City:</td><td>SALT LAKE CITY</td></tr> <tr><td>OpenDate:</td><td>2022-07-28</td></tr> <tr><td>Employer:</td><td>GLACIER BANCORP, INC</td></tr> <tr><td>Industry:</td><td>Computer</td></tr> <tr><td>Distance:</td><td>2</td></tr> <tr><td>CloseDate:</td><td>2022-08-27</td></tr> <tr><td>Remote:</td><td>N</td></tr> </table>
</details>
<tr><td></table>
