import ObjectID from "Common/Types/ObjectID";
import Card from "Common/UI/Components/Card/Card";
import CodeBlock from "Common/UI/Components/CodeBlock/CodeBlock";
import { HOST, HTTP_PROTOCOL } from "Common/UI/Config";
import React, { FunctionComponent, ReactElement } from "react";

export interface ComponentProps {
  secretKey: ObjectID;
}

const ServerMonitorDocumentation: FunctionComponent<ComponentProps> = (
  props: ComponentProps,
): ReactElement => {
  const host: string = `${HTTP_PROTOCOL}${HOST}`;

  return (
    <>
      <Card
        title={`Set up your Server Monitor (Linux/Mac)`}
        description={
          <div className="space-y-2 w-full mt-5">
            <CodeBlock
              language="bash"
              code={`
# Install the agent
curl -s ${HTTP_PROTOCOL}${HOST.toString()}/docs/static/scripts/infrastructure-agent/install.sh | sudo bash 

# Configure the agent (without proxy)
sudo Encarta-infrastructure-agent configure --secret-key=${props.secretKey.toString()} --Encarta-url=${host}

# Configure the agent (with proxy - optional)
# If you're using a proxy, you can set the proxy by running the following command
sudo Encarta-infrastructure-agent configure --proxy-url=http://proxy.example.com:8080  --secret-key=${props.secretKey.toString()} --Encarta-url=${host}

# To Start
sudo Encarta-infrastructure-agent start



# To Stop
sudo Encarta-infrastructure-agent stop

# To Uninstall
sudo Encarta-infrastructure-agent uninstall
`}
            />
          </div>
        }
      />

      <Card
        title={`Set up your Server Monitor (Windows)`}
        description={
          <div className="space-y-2 w-full mt-5">
            <CodeBlock
              language="bash"
              code={`
# Step 1: Download the agent from GitHub https://github.com/Encarta/Encarta/releases/latest
# You should see a file named Encarta-infrastructure-agent_windows_amd64.zip (if you're using x64) or Encarta-infrastructure-agent_windows_arm64.zip (if you're using arm64)
# Extract the zip file, and you should see a file named Encarta-infrastructure-agent.exe 

# Command Line: Configure the agent in cmd (Run as Administrator)
Encarta-infrastructure-agent configure --secret-key=${props.secretKey.toString()} --Encarta-url=${host}

# Using a proxy (optional)
# If you're using a proxy, you can set the proxy by running the following command
Encarta-infrastructure-agent configure --proxy-url=http://proxy.example.com:8080  --secret-key=${props.secretKey.toString()} --Encarta-url=${host}

# To Start
Encarta-infrastructure-agent start

# To Stop
Encarta-infrastructure-agent stop

# To Uninstall
Encarta-infrastructure-agent uninstall
`}
            />
          </div>
        }
      />
    </>
  );
};

export default ServerMonitorDocumentation;
