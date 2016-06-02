import com.gitblit.GitBlit
import com.gitblit.Keys
import com.gitblit.models.RepositoryModel
import com.gitblit.models.UserModel
import com.gitblit.utils.JGitUtils
import com.gitblit.utils.JGitUtils
import org.eclipse.jgit.lib.Repository
import org.eclipse.jgit.revwalk.RevCommit
import org.eclipse.jgit.transport.ReceiveCommand
import org.eclipse.jgit.transport.ReceiveCommand.Result
import org.slf4j.Logger

// Indicate we have started the script
logger.info("openshift hook triggered by ${user.username} for ${repository.name}")
def triggerUrl = repository.customFields.openshiftTrigger.replaceAll("master.ose.ulx.hu:8443", "kubernetes.default.svc")

// trigger the build
def _url = new URL(triggerUrl)
def _con = _url.openConnection()
_con.setRequestMethod("POST")
_con.setRequestProperty("User-Agent", "Gitblit")

// send post request
_con.setDoOutput(true)

logger.info("OpenShift response code: ${_con.responseCode}")

