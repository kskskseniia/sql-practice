WITH RECURSIVE employee_hierarchy AS (
    SELECT
        EmployeeID,
        Name,
        ManagerID,
        DepartmentID,
        RoleID
    FROM Employees
    WHERE EmployeeID = 1

    UNION ALL

    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    JOIN employee_hierarchy eh ON e.ManagerID = eh.EmployeeID
),
project_agg AS (
    SELECT
        e.EmployeeID,
        STRING_AGG(DISTINCT p.ProjectName, ', ' ORDER BY p.ProjectName) AS ProjectNames
    FROM Employees e
    LEFT JOIN Projects p ON e.DepartmentID = p.DepartmentID
    GROUP BY e.EmployeeID
),
task_agg AS (
    SELECT
        e.EmployeeID,
        STRING_AGG(t.TaskName, ', ' ORDER BY t.TaskName) AS TaskNames,
        COUNT(t.TaskID) AS TotalTasks
    FROM Employees e
    LEFT JOIN Tasks t ON e.EmployeeID = t.AssignedTo
    GROUP BY e.EmployeeID
),
subordinate_count AS (
    SELECT
        ManagerID,
        COUNT(*) AS TotalSubordinates
    FROM Employees
    WHERE ManagerID IS NOT NULL
    GROUP BY ManagerID
)
SELECT
    eh.EmployeeID,
    eh.Name AS EmployeeName,
    eh.ManagerID,
    d.DepartmentName,
    r.RoleName,
    pa.ProjectNames,
    ta.TaskNames,
    ta.TotalTasks,
    COALESCE(sc.TotalSubordinates, 0) AS TotalSubordinates
FROM employee_hierarchy eh
JOIN Departments d ON eh.DepartmentID = d.DepartmentID
JOIN Roles r ON eh.RoleID = r.RoleID
LEFT JOIN project_agg pa ON eh.EmployeeID = pa.EmployeeID
LEFT JOIN task_agg ta ON eh.EmployeeID = ta.EmployeeID
LEFT JOIN subordinate_count sc ON eh.EmployeeID = sc.ManagerID
ORDER BY eh.Name;