#!/bin/sh

test_description='switch basic functionality'

. ./test-lib.sh

test_expect_success 'setup' '
	test_commit first &&
	git branch first-branch &&
	test_commit second &&
	test_commit third &&
	git remote add origin nohost:/nopath &&
	git update-ref refs/remotes/origin/foo first-branch
'

test_expect_success 'switch branch no arguments' '
	test_must_fail git switch
'

test_expect_success 'switch branch' '
	git switch first-branch &&
	test_path_is_missing second.t
'

test_expect_success 'switch to a commit' '
	test_must_fail git switch master^{commit}
'

test_expect_success 'switch and detach' '
	test_when_finished git switch master &&
	git switch --detach master^{commit} &&
	test_must_fail git symbolic-ref HEAD
'

test_expect_success 'switch and detach current branch' '
	test_when_finished git switch master &&
	git switch master &&
	git switch --detach &&
	test_must_fail git symbolic-ref HEAD
'

test_expect_success 'switch and create branch' '
	test_when_finished git switch master &&
	git switch -c temp master^ &&
	test_cmp_rev master^ refs/heads/temp &&
	echo refs/heads/temp >expected-branch &&
	git symbolic-ref HEAD >actual-branch &&
	test_cmp expected-branch actual-branch
'

test_expect_success 'force create branch from HEAD' '
	test_when_finished git switch master &&
	git switch --detach master &&
	git switch -C temp &&
	test_cmp_rev master refs/heads/temp &&
	echo refs/heads/temp >expected-branch &&
	git symbolic-ref HEAD >actual-branch &&
	test_cmp expected-branch actual-branch
'

test_expect_success 'new orphan branch' '
	test_when_finished git switch master &&
	git switch --orphan new-orphan master^ &&
	test_commit orphan &&
	git cat-file commit refs/heads/new-orphan >commit &&
	! grep ^parent commit
'

test_expect_success 'switching ignores file of same branch name' '
	test_when_finished git switch master &&
	: >first-branch &&
	git switch first-branch &&
	echo refs/heads/first-branch >expected &&
	git symbolic-ref HEAD >actual &&
	test_commit expected actual
'

test_expect_success 'guess and create branch ' '
	test_when_finished git switch master &&
	test_must_fail git switch foo &&
	git switch --guess foo &&
	echo refs/heads/foo >expected &&
	git symbolic-ref HEAD >actual &&
	test_cmp expected actual
'

test_done
