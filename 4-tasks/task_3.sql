WITH RECURSIVE subordinate_tree AS (
    SELECT
        e.EmployeeID AS ManagerEmployeeID,
        s.EmployeeID AS SubordinateEmployeeID
    FROM Employees e
    JOIN Employees s ON s.ManagerID = e.EmployeeID

    UNION ALL

    SELECT
        st.ManagerEmployeeID,
        s.EmployeeID AS SubordinateEmployeeID
    FROM subordinate_tree st
    JOIN Employees s ON s.ManagerID = st.SubordinateEmployeeID
),
recursive_subordinate_count AS (
    SELECT
        ManagerEmployeeID,
        COUNT(*) AS TotalSubordinates
    FROM subordinate_tree
    GROUP BY ManagerEmployeeID
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
        STRING_AGG(t.TaskName, ', ' ORDER BY t.TaskName) AS TaskNames
    FROM Employees e
    LEFT JOIN Tasks t ON e.EmployeeID = t.AssignedTo
    GROUP BY e.EmployeeID
)
SELECT
    e.EmployeeID,
    e.Name AS EmployeeName,
    e.ManagerID,
    d.DepartmentName,
    r.RoleName,
    pa.ProjectNames,
    ta.TaskNames,
    rsc.TotalSubordinates
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
JOIN Roles r ON e.RoleID = r.RoleID
LEFT JOIN project_agg pa ON e.EmployeeID = pa.EmployeeID
LEFT JOIN task_agg ta ON e.EmployeeID = ta.EmployeeID
JOIN recursive_subordinate_count rsc ON e.EmployeeID = rsc.ManagerEmployeeID
WHERE r.RoleName = 'Менеджер'
  AND rsc.TotalSubordinates > 0
ORDER BY e.Name;