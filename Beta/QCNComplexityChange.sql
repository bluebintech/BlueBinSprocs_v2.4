select * from qcn.QCNComplexity

update qcn.QCNComplexity set Description = 'Greater than 5 Days' where Name = '1'
update qcn.QCNComplexity set Description = '2-5 Days' where Name = '2'
update qcn.QCNComplexity set Description = '1 Day' where Name = '3'
update qcn.QCNComplexity set Description = 'Less than 1 Day' where Name = '4'

/*Old Values
update qcn.QCNComplexity set Description = 'Many Nodes, Many Moves' where Name = '1'
update qcn.QCNComplexity set Description = 'Not Many Nodes, Many Moves' where Name = '2'
update qcn.QCNComplexity set Description = 'Many Nodes, Not Many Moves' where Name = '3'
update qcn.QCNComplexity set Description = 'Not Many Nodes, Not Many Moves' where Name = '4'
*/

select * from qcn.QCNComplexity