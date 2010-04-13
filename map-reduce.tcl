# 
#
# Simple implementation of the Map Reduce algorithm. This is 
# an algorithm is very scalable. Use of it is well advised
# for any time a problem can be easily divided. For example,
# any time we are doing an operation on each element of a list
# or each element of an array.
#
# Functional programming initially looks very confusing. Read up on it in 
# Wikipedia or other sources until this code makes sense. Also read the Joel
# on Software piece below.
# 
# @author <a href="mailto:jade@rubick.com">Jade Rubick</a>
#
# See http://www.joelonsoftware.com/items/2006/08/01.html
#
#

namespace eval vsmr {}
# enable inline testing
vs_enable_test vsmr

vs_test vsmr::map_double { } {
    array set a [list 1 1 2 2 3 3]
    vsmr::map_array {vsmr::map_double_test} a
    test::assert_equals "Array values should be doubled" [list 1 2 2 4 3 6] [array get a] 

    array set b [list 1 3]
    vsmr::map_array {vsmr::map_double_test} b
    test::assert_equals "Testing single array value" [list 1 6] [array get b] 

    array set c [list]
    vsmr::map_array {vsmr::map_double_test} c
    test::assert_equals "Testing empty array" [list] [array get c] 

    return true
}

ad_proc -public vsmr::map_array { proc_name array_name } {
    A simple implementation of the map portion of the vsmr algorithm.

    proc_name is a proc that takes an element of an array and
    returns a modified element of the same type. An example proc is
    vsmr::map_double_test
} {
    upvar 1 $array_name arr

    foreach {key value} [array get arr] {
        set arr($key) [$proc_name $arr($key)]
    }
}

vs_test vsmr::map_list { } {
    set list1 [list 3 5 7]
    vsmr::map_list {vsmr::map_double_test} list1
    test::assert_equals "Value should be double" [list 6 10 14] $list1

    set list1 [list 3]
    vsmr::map_list {vsmr::map_double_test} list1
    test::assert_equals "With only one value, should double" [list 6] $list1

    set list1 [list]
    vsmr::map_list {vsmr::map_double_test} list1
    test::assert_equals "Empty list should return empty list" [list] $list1

    return true
}

ad_proc -public vsmr::map_list { proc_name list_name } {
    A simple implementation of the map portion of the vsmr algorithm.

    proc_name is a proc that takes an element of an array and
    returns a modified element of the same type. An example proc is
    vsmr::map_double_test
} {
    upvar 1 $list_name mylist

    set new_list [list]
    foreach value $mylist {
        lappend new_list [$proc_name $value]
    }
    # overwrite original list
    set mylist $new_list
}


vs_test vsmr::reduce_sum { } {
    array set a [list a 2 b 5 c 8]
    set summed [vsmr::reduce_array {vsmr::reduce_sum_test} a]
    test::assert_equals "Value should be summed" 15 $summed

    array set b [list 1 3]
    set summed [vsmr::reduce_array {vsmr::reduce_sum_test} b]
    test::assert_equals "With only one value, should return that value" 3 $summed

    array set c [list]
    set summed [vsmr::reduce_array {vsmr::reduce_sum_test} c]
    test::assert_equals "With no value should return 0 or initial value" 0 $summed

    return true
}

ad_proc -public vsmr::reduce_array { 
    {
        -initial_value "0"
    }
    proc_name array_name 
} {
    A simple implementation of the reduce portion of the vsmr algorithm.

    proc_name is a proc that takes an element of an array and
    returns a modified element of the same type. 
} {
    set reduced $initial_value
    upvar 1 $array_name arr

    foreach {key value} [array get arr] {
        set reduced [$proc_name $reduced $arr($key)]
    }

    return $reduced
}

vs_test vsmr::reduce_list { } {
    set list1 [list 2 5 8]
    set summed [vsmr::reduce_list {vsmr::reduce_sum_test} list1]
    test::assert_equals "Value should be summed" 15 $summed

    set list1 [list 3]
    set summed [vsmr::reduce_list {vsmr::reduce_sum_test} list1]
    test::assert_equals "With only one value, should return that value" 3 $summed

    set list1 [list]
    set summed [vsmr::reduce_list {vsmr::reduce_sum_test} list1]
    test::assert_equals "With no value should return 0 or initial value" 0 $summed

    return true
}

ad_proc -public vsmr::reduce_list { 
    {
        -initial_value "0"
    }
    proc_name list_name 
} {
    A simple implementation of the reduce portion of the vsmr algorithm.

    proc_name is a proc that takes an element of an array and
    returns a modified element of the same type. 
} {
    set reduced $initial_value
    upvar 1 $list_name my_list

    foreach value $my_list {
        set reduced [$proc_name $reduced $value]
    }

    return $reduced
}

ad_proc -public vsmr::map_double_test { value } {
    A test proc for the vsmr algorithm. This test proc is used
    to double the value of each element of an array.
} {
    return [expr $value * 2]
} 


ad_proc -public vsmr::reduce_sum_test { val1 val2 } {
    Note this is a functional style, and the value of the sum will be passed in as 
    the first or second argument each time. That's why you get a sum.
} {
    return [expr $val1 + $val2]
} 

