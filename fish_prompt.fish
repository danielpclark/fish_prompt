function fish_prompt
  if not set -q -g __fish_robbyrussell_functions_defined
    set -g __fish_robbyrussell_functions_defined
    function _git_branch_name
      echo (git rev-parse --abbrev-ref HEAD ^/dev/null)
    end

    function _is_git_dirty
      echo (git status -s --ignore-submodules=dirty ^/dev/null)
    end

    function _is_git_repo
      type -q git; or return 1
      git status -s >/dev/null ^/dev/null
    end

    function _is_git_branch
      echo (git branch ^/dev/null; or false)
    end

    function _git_upstream_current_ref
      echo (git rev-parse --short (git remote ^/dev/null)/(git rev-parse --abbrev-ref HEAD ^/dev/null) ^/dev/null; or echo "[unpub]")
    end

    function _git_current_ref
      echo (git rev-parse --short HEAD ^/dev/null; or echo "[noref]")
    end

    function _hg_branch_name
      echo (hg branch ^/dev/null)
    end

    function _is_hg_dirty
      echo (hg status -mard ^/dev/null)
    end

    function _is_hg_repo
      type -q hg; or return 1
      hg summary >/dev/null ^/dev/null
    end

    function _repo_branch_name
      eval "_$argv[1]_branch_name"
    end

    function _is_repo_dirty
      eval "_is_$argv[1]_dirty"
    end

    function _repo_type
      if _is_hg_repo
        echo 'hg'
      else if _is_git_repo
        echo 'git'
      end
    end
  end

  set -l cyan (set_color -o cyan)
  set -l yellow (set_color -o yellow)
  set -l red (set_color -o red)
  set -l blue (set_color -o blue)
  set -l normal (set_color normal)

  set -l cwd $cyan(basename (prompt_pwd))

  switch (_git_current_ref)
    case (_git_upstream_current_ref)
      set -g upcolor $cyan
      set -g pub $cyan
    case '[noref]'
      set -g upcolor $red
      set -g pub $red
    case '*'
      set -g upcolor $yellow
      switch (_git_upstream_current_ref)
        case "[unpub]"
          set -g pub $red
        case '*'
          set -g pub $upcolor
      end
  end

  set -l refs (echo $pub(_git_upstream_current_ref)"$normal/$upcolor"(_git_current_ref))

  if [ (_is_git_branch) ]
    set -g branch_color $cyan
  else
    set -g branch_color $red
  end

  set -l repo_type (_repo_type)
  if [ $repo_type ]
    set -l repo_branch $branch_color(_repo_branch_name $repo_type)
    set repo_info "$blue $repo_type($repo_branch$normal:$refs$blue)"

    if [ (_is_repo_dirty $repo_type) ]
      set -l dirty "$yellow ✗"
      set repo_info "$repo_info$dirty"
    else
      set -l dirty "$cyan ✔"
      set repo_info "$repo_info$dirty"
    end
  else
    set repo_info $blue" #$normal:"
  end

  echo -n -s $cwd $repo_info $normal ' '
end
