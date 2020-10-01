local U = import "./utilities.libsonnet";
local V = import "./validate.libsonnet";

local Service = {
    BlockIOConfig :: import "./Service/BlockIOConfig.libsonnet",
    Build         :: import "./Service/Build.libsonnet",
    Deploy        :: import "./Service/Deploy.libsonnet",
    CredentialSpec :: import "./Service/CredentialSpec.libsonnet",
    Healthcheck   :: import "./Service/Healthcheck.libsonnet",
    ULimits       :: import "./Service/ULimits.libsonnet", 
    Logging       :: import "./Service/Logging.libsonnet",
    Config        :: import "./Service/Config.libsonnet",
    Secret        :: import "./Service/Secret.libsonnet",
    Extends       :: import "./Service/Extends.libsonnet",
    DependsOn     :: import "./Service/DependsOn.libsonnet",
    Port          :: import "./Service/Port.libsonnet",
    Volume        :: import "./Service/Volume.libsonnet"
};

local combiner = U.map_combiner({ });

local combine = U.combine( U.empty, combiner );
local mixin = U.mixin( combine );

local new = function(
    
        mixins = [ ]

        , blkio_config  = null // = None BlockIOConfig.Type
        , build         = null // = None Build.Type
        , cap_add       = null // = None ( List Text )
        , cap_drop      = null // = None ( List Text )
        , cgroup_parent = null // = None Text
        , command       = null // = None ( List Text )
        , configs       = null // = None ( List Config.Type )
        , container_name = null // = None Text
        , cpu_count     = null // = None Natural
        , cpu_percent   = null // = None Natural
        , cpu_period    = null // = None Text
        , cpu_quota     = null // = None Text
        , cpu_rt_period = null // = None Text
        , cpu_rt_runtime = null // = None Text
        , cpu_shares    = null // = None Text
        , cpuset        = null // = None Text
        , credential_spec = null // = None CredentialSpec.Type
        , depends_on    = null // = None ( Map Text DependsOn.Type )
        , deploy        = null // = None Deploy.Type
        , device_cgroup_rules = null // = None ( List Text )
        , devices       = null // = None ( List Text )
        , dns           = null // = None ( List Text )
        , dns_opt       = null // = None ( List Text )
        , dns_search    = null // = None ( List Text )
        , domainname    = null // = None Text
        , entrypoint    = null // = None ( List Text )
        , env_file      = null // = None ( List Text )
        , environment   = null // = None ( Map Text Text )
        , expose        = null // = None ( List Text )
        , extends       = null // = None Extends.Type
        , external_links = null // = None ( List Text )
        , extra_hosts   = null // = None ( Map Text Text )
        , group_add     = null // = None ( List Text )
        , healthcheck   = null // = None Healthcheck.Type
        , hostname      = null // = None Text
        , image         = null // = None Text
        , init          = null // = None Bool
        , ipc           = null // = None Text
        , isolation     = null // = None Text
        , labels        = null // = None ( Map Text Text )
        , links         = null // = None ( List Text )
        , logging       = null // = None Logging.Type
        , mac_address   = null // = None Text
        , mem_swappiness = null // = None Natural
        , memswap_limit = null // = None Text
        , network_mode  = null // = None Text
        , networks      = null // = None ( Map Text Network.Type ) 
        , oom_kill_disable = null // = None Bool
        , oom_score_adj = null // = None Integer
        , pid           = null // = None Text
        , pid_limit     = null // = None Integer
        , platform      = null // = None Text
        , ports         = null // = None ( List Port.Type )
        , privileged    = null // = None Bool
        , pull_policy   = null // = None Text
        , read_only     = null // = None Bool
        , restart       = null // = None Text
        , secret        = null // = None ( List Secret.Type )
        , security_opt  = null // = None ( List Text )
        , shm_size      = null // = None Text 
        , stdin_open    = null // = None Bool
        , stop_grace_period = null // = None Text
        , stop_signal   = null // = None Text
        , sysctls       = null // = None ( Map Text Text )
        , tmpfs         = null // = None ( List Text )
        , tty           = null // = None Bool
        , ulimits       = null // = None ( Map Text ULimits.Type )
        , user          = null // = None Text
        , userns_mode   = null // = None Text
        , volumes       = null // = None ( Map Text Volume.Type )
        , volumes_from  = null // = None ( List Text )
        , working_dir   = null // = None Text

    )
    mixin( mixins, {

        [ U.key( kv ) ] : U.value( kv ) for kv in [

            V.optional( "blkio_config", blkio_config ),
            V.optional( "build", build ),
            V.optional( "cap_add", cap_add ),
            V.optional( "cap_drop", cap_drop ),
            V.optional( "cgroup_parent", cgroup_parent ),
            V.optional( "command", command ),
            V.optional( "configs", configs ),
            V.optional( "container_name", container_name ),
            V.optional( "cpu_count", cpu_count ),
            V.optional( "cpu_percent", cpu_percent ),
            V.optional( "cpu_period", cpu_period ),
            V.optional( "cpu_quota", cpu_quota ),
            V.optional( "cpu_rt_period", cpu_rt_period ),
            V.optional( "cpu_rt_runtime", cpu_rt_runtime ),
            V.optional( "cpu_shares", cpu_shares ),
            V.optional( "cpuset", cpuset ),
            V.optional( "credential_spec", credential_spec ),
            V.optional( "depends_on", depends_on ),
            V.optional( "deploy", deploy ),
            V.optional( "device_cgroup_rules", device_cgroup_rules ),
            V.optional( "devices", devices ),
            V.optional( "dns", dns ),
            V.optional( "dns_opt", dns_opt ),
            V.optional( "dns_search", dns_search ),
            V.optional( "domainname", domainname ),
            V.optional( "entrypoint", entrypoint ),
            V.optional( "env_file", env_file ),
            V.optional( "environment", environment ),
            V.optional( "expose", expose ),
            V.optional( "extends", extends ),
            V.optional( "external_links", external_links ),
            V.optional( "extra_hosts", extra_hosts ),
            V.optional( "group_add", group_add ),
            V.optional( "healthcheck", healthcheck ),
            V.optional( "hostname", hostname ),
            V.optional( "image", image ),
            V.optional( "init", init ),
            V.optional( "ipc", ipc ),
            V.optional( "isolation", isolation ),
            V.optional( "labels", labels ),
            V.optional( "links", links ),
            V.optional( "logging", logging ),
            V.optional( "mac_address", mac_address ),
            V.optional( "mem_swappiness", mem_swappiness ),
            V.optional( "memswap_limit", memswap_limit ),
            V.optional( "network_mode", network_mode ),
            V.optional( "networks", networks ),
            V.optional( "oom_kill_disable", oom_kill_disable ),
            V.optional( "oom_score_adj", oom_score_adj ),
            V.optional( "pid", pid ),
            V.optional( "pid_limit", pid_limit ),
            V.optional( "platform", platform ),
            V.optional( "ports", ports ),
            V.optional( "privileged", privileged ),
            V.optional( "pull_policy", pull_policy ),
            V.optional( "read_only", read_only ),
            V.optional( "restart", restart ),
            V.optional( "secret", secret ),
            V.optional( "security_opt", security_opt ),
            V.optional( "shm_size", shm_size ),
            V.optional( "stdin_open", stdin_open ),
            V.optional( "stop_grace_period", stop_grace_period ),
            V.optional( "stop_signal", stop_signal ),
            V.optional( "sysctls", sysctls ),
            V.optional( "tmpfs", tmpfs ),
            V.optional( "tty", tty ),
            V.optional( "ulimits", ulimits ),
            V.optional( "user", user ),
            V.optional( "userns_mode", userns_mode ),
            V.optional( "volumes", volumes ),
            V.optional( "volumes_from", volumes_from ),
            V.optional( "working_dir", working_dir )
         
        ]

    });

Service + {
    new :: new,
    combine :: combine,

    ports :: {
        mappings( mappings ) :: mappings,
    },

    depends_on( services ) :: services,
    //
    // The compose spec allows for a little more nuance here but as I am currently targeting
    // docker-compose I'm going to stick to what ever it will consume as of 3.8
    //
    // ( 
    //
    //     local depends_on( name ) = ([ name, Service.DependsOn.new( ) ]);
    //
    //     U.to_object( std.map( depends_on, services ) )
    //
    // ),
}
