# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include test::defer
class test::defer {
  notify { 'message':
    message => Deferred(
      'inline_epp',
      [
        'VAULT_VALUE=<%= unwrap($secret) %>',
        {'secret'=> Sensitive('a thing') }
      ]
    )
  }
}
