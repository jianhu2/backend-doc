# 查看配置文件

```  git config --global -l```


# 修改配置文件

```
[url "ssh://git@dev.gitlab.com/"]
                insteadOf = https://dev.gitlab.com/
[user]
        name = kelley_h
        email = eamil@jianhu.xyz
[user]
        name= jianhu
        email= eamil@jianhu.xyz

[url "ssh://git@github.com/"]
               insteadOf = https://github.com/

```


# 回滚本地仓库到指定分支：
git reset --hard c5d15a6613c3e39ba3947066b6a13e1b39ed99c7

# 解决拉取git权限失败
git config --global --unset http.proxy

# 强制push到远程
git push origin HEAD --force

# 强制拉取远程代码到本地：
git reset --hard origin/3.4

# 删除远程tag

git push origin  tag -d  v1.0.1

# 删除本地tag
git tag -d tag_name


# 删除远程分支：
git push origin --delete branch_name



# 创建tag：
git tag -a rxhf-3.1.3

# 推送本地标签
git push origin master --tags


# go build 要求输入用户名密码，https替换为git请求方式。

git config --global url."git@dev.gitlab.com:".insteadOf "https://dev.gitlab.com/"


git config --global url."git@github.com:".insteadOf "https://github.com/"

# 合并另一个分支的指定commit
git cherry-pick 8842688d****


# 删除指定commit
git rebase -i bd5dbf378*****


# 重设远程仓库：
git remote set-url origin git@dev.gitlab.com:go/items.git

# 打包标头和标签以便高效的存储库访问
git pack-refs --all

# git解决Enter passphrase for key ‘/root/.ssh/id_rsa’: 重复输入密码问题
``` 
ssh-keygen -p
```

这里只是删除密码 ssh的pub不会改变。
Enter file in which the key is (/Users/haoyangruanjian/.ssh/id_rsa):直接点回车，
Enter new passphrase (empty for no passphrase):也是直接回车不设置密码


# 测试与github连接
ssh -T git@github.com

参考：
- https://docs.github.com/cn/authentication/connecting-to-github-with-ssh/testing-your-ssh-connection