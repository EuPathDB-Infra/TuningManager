 package ApiCommonData::Load::TuningConfig::TuningIndex;

use strict;
use Data::Dumper;
use ApiCommonData::Load::TuningConfig::Log;

sub new {
    my ($class,
	$name,       # name of database table
        $table,      # "<owner>.<table>" to create index on
        $columnList, # comma-separated list of columns to index
        $dbh)        # database handle
	= @_;

    my $self = {};

    bless($self, $class);
    $self->{name} = $name;
    $self->{table} = $table;

    $columnList =~ s/\n//g;  # remove newlines from column list
    $columnList =~ s/^ *//g;  # remove leading spaces
    $columnList =~ s/ *$//g;  # remove trailing spaces

    $self->{columnList} = $columnList;

    my ($schema, $simpleTable) = split(/\./, $table);
    $self->{schema} = $schema;
    $self->{simpleTable} = $simpleTable;

    # check that such an index exists on this table
    ApiCommonData::Load::TuningConfig::Log::addLog("Checking for index on $self->{table} ($self->{columnList})");

    my $columnNumber;
    my @aicInstances;  # occurrences of ALL_INDEX_COLUMNS in query
    my @whereTerms;
    foreach my $column (split(/\,/, $columnList)) {
      $columnNumber++;
      push(@aicInstances, "all_ind_columns aic$columnNumber");
      push(@whereTerms, "aic$columnNumber.column_position = $columnNumber and aic$columnNumber.column_name = upper(regexp_replace('$column', '[[:space:]]', '')) and aic$columnNumber.index_name = aic1.index_name")
    }
    my $sql = "select index_name, max(column_position)\n"
      . "from all_ind_columns where index_name in (\n"
	. "select aic1.index_name\nfrom " .
	  join(', ', @aicInstances) .
	    "\n where aic1.table_owner = upper(trim('" . $self->{schema}
	      . " ')) and aic1.table_name = upper(trim('" . $self->{simpleTable} . "')) \n  and "
		. join("\n  and ", @whereTerms)
		  . ") group by index_name";

    my $stmt = $dbh->prepare($sql);
    $stmt->execute()
      or ApiCommonData::Load::TuningConfig::Log::addErrorLog("\n" . $dbh->errstr . "\n");

    my $indexExists;
    while (my ($index_name, $columnCount) = $stmt->fetchrow_array()) {
      $indexExists = 1;
      ApiCommonData::Load::TuningConfig::Log::addLog("WARNING: the database contains the index "
						     . $index_name
						     . ", which is an extension of the tuningIndex "
						     . $self->{name}
						     . " -- is the tuningManager config file out of date?")
	  if $columnCount > $columnNumber;
    }
    $stmt->finish();

    $self->{exists} = $indexExists;

    return $self;
}


sub exists {
    my ($self) = @_;

    return $self->{exists};
}

sub create {
    my ($self, $dbh) = @_;

    my $startTime = time;

    ApiCommonData::Load::TuningConfig::Log::setUpdateNeededFlag();

    ApiCommonData::Load::TuningConfig::Log::addLog("creating index " . $self->{name});
    my $sql = $self->getCreateStatement();
    my $stmt = $dbh->prepare($sql);

    my  $message = $sql;
    $message =~ s/create/must create/;
    ApiCommonData::Load::TuningConfig::Log::addLog($message);

    $stmt->execute()
      or ApiCommonData::Load::TuningConfig::Log::addErrorLog("\n" . $dbh->errstr . "\n");
    $stmt->finish();

    ApiCommonData::Load::TuningConfig::Log::addLog(time - $startTime .
						  " seconds to rebuild index " .
						  $self->{name});

}

sub getCreateStatement {
    my ($self) = @_;

    my $sql = <<SQL;
create index $self->{name} on $self->{table} ($self->{columnList})
SQL

    return $sql;
}

1;
