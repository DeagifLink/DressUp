function table.GetByMemberValue(tbl, member, value)
	for k, v in pairs( tbl ) do
		if(string.lower(v[member]) == string.lower(value))then
            return v
        end
	end
    return nil
end