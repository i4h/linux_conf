_script()
{
  _script_commands=$(cd $repoDir/linux_conf; lc_scripts/lc_notes.sh -k; cd - > /dev/null)

  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "${_script_commands}" -- ${cur}) )

  return 0
}
complete -o nospace -F _script lc_notes
