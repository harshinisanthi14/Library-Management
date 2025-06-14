-- Problem 1: Comprehensive Library Report
use odinlibrary;
-- 1. Books Not Loaned Out in the Last 6 Months
select books.title from books 
where books.bookid not in
(select bookid from loans
where loandate >= date_sub(curdate(), interval 6 month));

-- 2. Top Members by Number of Books Borrowed in the Last Year
select members.firstname, members.lastname, count(loans.loanid) as books_borrowed, members.membershipstartdate 
from members
join loans 
on loans.memberid = members.memberid
where loandate >= date_sub(curdate(),interval 1 year)
group by members.memberid
order by books_borrowed desc
limit 5;

-- 3. Overdue Books Report
select books.title, members.firstname, members.lastname, datediff(curdate(), duedate) as daysoverdue
from loans
join books
on loans.bookid = books.bookid
join members
on loans.memberid = members.memberid
where returndate is null and duedate < curdate()
order by daysoverdue desc;

-- 4. Top 3 Most Borrowed Categories
select categoryname, count(bookcategories.bookid) as borrowcount
from categories
join bookcategories
on categories.categoryid = bookcategories.Categoryid
join loans
on bookcategories.BookID = loans.BookID
group by categories.CategoryID
order by borrowcount desc
limit 3;

-- 5. Are there any books Belonging to Multiple Categories
select books.title, count(bookcategories.CategoryID) as categorycount
from books
join bookcategories
on bookcategories.BookID = books.BookID
group by books.bookid
having categorycount > 1;

-- Problem 2: Advanced Library Data Analysis

-- 6. Average Number of Days Books Are Kept
select round(avg(datediff(returndate,loandate))) as average_days
from loans
where returned is not null;

-- 7. Members with Reservations but No Loans in the Last Year
select members.firstname, members.lastname,books.title
from members 
join reservations 
on reservations.memberid = members.memberid
join books 
on books.bookid = reservations.bookid
where members.memberid not in
(select members.memberid from loans where loandate >= date_sub(curdate(),interval 1 year));

-- 8. Percentage of Books Loaned Out per Category
select categories.categoryname, 
round((count(loans.bookid) / count(bookcategories.bookid)) * 100, 2) as loan_percentage
from categories
join bookcategories 
on categories.CategoryID = bookcategories.CategoryID
left join loans
on loans.BookID = bookcategories.BookID
and returned = False
group by categories.CategoryID;

-- 9. Total Number of Loans and Reservations Per Member
select members.FirstName, members.lastname, count(loans.loanid) as total_loans, count(reservations.reservationid) as total_reservations
from members
left join loans
on members.memberid = loans.memberid
left join reservations
on reservations.MemberID = members.MemberID
group by members.memberid 
order by total_loans desc, total_reservations desc;

-- 10. Find Members Who Borrowed Books by the Same Author More Than Once
select members.firstname, members.lastname, authors.FirstName as author_firstname, authors.LastName as author_lastname, 
count(distinct loans.bookid) as books_by_author
from members
join loans 
on loans.memberid = members.memberid
join books 
on books.bookid = loans.bookid
join authors
on authors.authorid = books.authorid
group by members.memberid, authors.authorid
having books_by_author > 1;

-- 11. List Members Who Have Both Borrowed and Reserved the Same Book
select M.FirstName, M.LastName, B.Title
from Members M
join Loans L 
on M.MemberID = L.MemberID
join Reservations R 
on M.MemberID = R.MemberID
join Books B 
on L.BookID = B.BookID and R.BookID = B.BookID
group by M.MemberID, B.BookID;

-- 12. Books Loaned and Never Returned
select books.title, members.firstname, members.lastname, loandate, duedate  from loans
join books
on loans.bookid = books.bookid
join members
on members.memberid = loans.memberid
where returned = False;

-- 13. Authors with the Most Borrowed Books
select authors.firstname, authors.lastname, count(loans.bookid) as borrow_count
from authors
join books
on authors.authorid = books.authorid
join loans
on loans.bookid = books.bookid
group by authors.authorid
order by borrow_count desc
limit 5;

-- 14. Books Borrowed by Members Who Joined in the Last 6 Months
select B.Title, M.FirstName, M.LastName, M.MembershipStartDate
from Books B
join Loans L ON B.BookID = L.BookID
join Members M ON L.MemberID = M.MemberID
where M.MembershipStartDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH);