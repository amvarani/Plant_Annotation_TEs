# -*- encoding:ascii -*-
from mako import runtime, filters, cache
UNDEFINED = runtime.UNDEFINED
__M_dict_builtin = dict
__M_locals_builtin = locals
_magic_number = 6
_modified_time = 1392055148.655435
_template_filename=u'templates/webapps/galaxy/base_panels.mako'
_template_uri=u'/webapps/galaxy/base_panels.mako'
_template_cache=cache.Cache(__name__, _modified_time)
_source_encoding='ascii'
_exports = ['masthead', 'javascripts', 'late_javascripts', 'get_user_json', 'title']


def _mako_get_namespace(context, name):
    try:
        return context.namespaces[(__name__, name)]
    except KeyError:
        _mako_generate_namespaces(context)
        return context.namespaces[(__name__, name)]
def _mako_generate_namespaces(context):
    pass
def _mako_inherit(template, context):
    _mako_generate_namespaces(context)
    return runtime._inherit_from(context, u'/base/base_panels.mako', _template_uri)
def render_body(context,**pageargs):
    context.caller_stack._push_frame()
    try:
        __M_locals = __M_dict_builtin(pageargs=pageargs)
        __M_writer = context.writer()
        # SOURCE LINE 1
        __M_writer(u'\n\n')
        # SOURCE LINE 4
        __M_writer(u'\n\n')
        # SOURCE LINE 12
        __M_writer(u'\n\n')
        # SOURCE LINE 38
        __M_writer(u'\n\n')
        # SOURCE LINE 55
        __M_writer(u'\n\n')
        # SOURCE LINE 249
        __M_writer(u'\n')
        return ''
    finally:
        context.caller_stack._pop_frame()


def render_masthead(context):
    context.caller_stack._push_frame()
    try:
        h = context.get('h', UNDEFINED)
        app = context.get('app', UNDEFINED)
        trans = context.get('trans', UNDEFINED)
        def tab(id,display,href,onclick=False,target='_parent',visible=True,extra_class='',menu_options=None):
            context.caller_stack._push_frame()
            try:
                self = context.get('self', UNDEFINED)
                len = context.get('len', UNDEFINED)
                __M_writer = context.writer()
                # SOURCE LINE 66
                __M_writer(u'\n')
                # SOURCE LINE 69
                __M_writer(u'    \n        ')
                # SOURCE LINE 70

                cls = ""
                a_cls = ""
                extra = ""
                if extra_class:
                    cls += " " + extra_class
                if self.active_view == id:
                    cls += " active"
                if menu_options:
                    cls += " dropdown"
                    a_cls += " dropdown-toggle"
                    extra = "<b class='caret'></b>"
                style = ""
                if not visible:
                    style = "display: none;"
                
                
                # SOURCE LINE 85
                __M_writer(u'\n        <li class="')
                # SOURCE LINE 86
                __M_writer(unicode(cls))
                __M_writer(u'" style="')
                __M_writer(unicode(style))
                __M_writer(u'">\n')
                # SOURCE LINE 87
                if href:
                    # SOURCE LINE 88
                    __M_writer(u'                <a class="')
                    __M_writer(unicode(a_cls))
                    __M_writer(u'" data-toggle="dropdown" target="')
                    __M_writer(unicode(target))
                    __M_writer(u'" href="')
                    __M_writer(unicode(href))
                    __M_writer(u'">')
                    __M_writer(unicode(display))
                    __M_writer(unicode(extra))
                    __M_writer(u'</a>\n')
                    # SOURCE LINE 89
                else:
                    # SOURCE LINE 90
                    __M_writer(u'                <a class="')
                    __M_writer(unicode(a_cls))
                    __M_writer(u'" data-toggle="dropdown">')
                    __M_writer(unicode(display))
                    __M_writer(unicode(extra))
                    __M_writer(u'</a>\n')
                    pass
                # SOURCE LINE 92
                if menu_options:
                    # SOURCE LINE 93
                    __M_writer(u'                <ul class="dropdown-menu">\n')
                    # SOURCE LINE 94
                    for menu_item in menu_options:
                        # SOURCE LINE 95
                        if not menu_item:
                            # SOURCE LINE 96
                            __M_writer(u'                            <li class="divider"></li>\n')
                            # SOURCE LINE 97
                        else:
                            # SOURCE LINE 98
                            __M_writer(u'                            <li>\n')
                            # SOURCE LINE 99
                            if len ( menu_item ) == 1:
                                # SOURCE LINE 100
                                __M_writer(u'                                ')
                                __M_writer(unicode(menu_item[0]))
                                __M_writer(u'\n')
                                # SOURCE LINE 101
                            elif len ( menu_item ) == 2:
                                # SOURCE LINE 102
                                __M_writer(u'                                ')
                                name, link = menu_item 
                                
                                __M_writer(u'\n')
                                # SOURCE LINE 103
                                if onclick:
                                    # SOURCE LINE 104
                                    __M_writer(u'                                    <a href="')
                                    __M_writer(unicode(link))
                                    __M_writer(u'" onclick="Galaxy.frame_manager.frame_new({title: \'')
                                    __M_writer(unicode(name))
                                    __M_writer(u"', type: 'url', content: '")
                                    __M_writer(unicode(link))
                                    __M_writer(u'\'}); return false;">')
                                    __M_writer(unicode(name))
                                    __M_writer(u'</a>\n')
                                    # SOURCE LINE 105
                                else:
                                    # SOURCE LINE 106
                                    __M_writer(u'                                    <a href="')
                                    __M_writer(unicode(link))
                                    __M_writer(u'">')
                                    __M_writer(unicode(name))
                                    __M_writer(u'</a>\n')
                                    pass
                                # SOURCE LINE 108
                            else:
                                # SOURCE LINE 109
                                __M_writer(u'                                ')
                                name, link, target = menu_item 
                                
                                __M_writer(u'\n                                <a target="')
                                # SOURCE LINE 110
                                __M_writer(unicode(target))
                                __M_writer(u'" href="')
                                __M_writer(unicode(link))
                                __M_writer(u'">')
                                __M_writer(unicode(name))
                                __M_writer(u'</a>\n')
                                pass
                            # SOURCE LINE 112
                            __M_writer(u'                            </li>\n')
                            pass
                        pass
                    # SOURCE LINE 115
                    __M_writer(u'                </ul>\n')
                    pass
                # SOURCE LINE 117
                __M_writer(u'        </li>\n    ')
                return ''
            finally:
                context.caller_stack._pop_frame()
        _ = context.get('_', UNDEFINED)
        __M_writer = context.writer()
        # SOURCE LINE 58
        __M_writer(u'\n\n')
        # SOURCE LINE 61
        __M_writer(u'    <div style="position: relative; right: -50%; float: left;">\n    <div style="display: block; position: relative; right: 50%;">\n\n    <ul class="nav navbar-nav" border="0" cellspacing="0">\n    \n    ')
        # SOURCE LINE 118
        __M_writer(u'\n\n')
        # SOURCE LINE 121
        __M_writer(u'    ')
        __M_writer(unicode(tab( "analysis", _("Analyze Data"), h.url_for( controller='/root', action='index' ) )))
        __M_writer(u'\n    \n')
        # SOURCE LINE 124
        __M_writer(u'    ')
        __M_writer(unicode(tab( "workflow", _("Workflow"), h.url_for( controller='/workflow', action='index' ) )))
        __M_writer(u'\n\n')
        # SOURCE LINE 127
        __M_writer(u'    ')

        menu_options = [ 
                        [ _('Data Libraries'), h.url_for( controller='/library', action='index') ],
                        None,
                        [ _('Published Histories'), h.url_for( controller='/history', action='list_published' ) ],
                        [ _('Published Workflows'), h.url_for( controller='/workflow', action='list_published' ) ],
                        [ _('Published Visualizations'), h.url_for( controller='/visualization', action='list_published' ) ],
                        [ _('Published Pages'), h.url_for( controller='/page', action='list_published' ) ]
                       ] 
        tab( "shared", _("Shared Data"), h.url_for( controller='/library', action='index'), menu_options=menu_options )
            
        
        # SOURCE LINE 137
        __M_writer(u'\n    \n')
        # SOURCE LINE 140
        __M_writer(u'    ')

        menu_options = [
                         [ _('Sequencing Requests'), h.url_for( controller='/requests', action='index' ) ],
                         [ _('Find Samples'), h.url_for( controller='/requests', action='find_samples_index' ) ],
                         [ _('Help'), app.config.get( "lims_doc_url", "http://main.g2.bx.psu.edu/u/rkchak/p/sts" ), "galaxy_main" ]
                       ]
        tab( "lab", "Lab", None, menu_options=menu_options, visible=( trans.user and ( trans.user.requests or trans.app.security_agent.get_accessible_request_types( trans, trans.user ) ) ) )
            
        
        # SOURCE LINE 147
        __M_writer(u'\n\n\n                                    \n')
        # SOURCE LINE 152
        __M_writer(u'    ')

        menu_options = [
                         [_('New Track Browser'), h.url_for( controller='/visualization', action='trackster' )],
                         [_('Saved Visualizations'), h.url_for( controller='/visualization', action='list' )]
                       ]
        tab( "visualization", _("Visualization"), h.url_for( controller='/visualization', action='list' ), menu_options=menu_options, onclick=True )
            
        
        # SOURCE LINE 158
        __M_writer(u'\n\n')
        # SOURCE LINE 161
        if app.config.get_bool( 'enable_cloud_launch', False ):
            # SOURCE LINE 162
            __M_writer(u'        ')

            menu_options = [
                             [_('New Cloud Cluster'), h.url_for( controller='/cloudlaunch', action='index' ) ],
                           ]
            tab( "cloud", _("Cloud"), h.url_for( controller='/cloudlaunch', action='index'), menu_options=menu_options )
                    
            
            # SOURCE LINE 167
            __M_writer(u'\n')
            pass
        # SOURCE LINE 169
        __M_writer(u'\n')
        # SOURCE LINE 171
        __M_writer(u'    ')
        __M_writer(unicode(tab( "admin", "Admin", h.url_for( controller='/admin', action='index' ), extra_class="admin-only", visible=( trans.user and app.config.is_admin_user( trans.user ) ) )))
        __M_writer(u'\n    \n')
        # SOURCE LINE 174
        __M_writer(u'    ')

        menu_options = []
        if app.config.biostar_url:
            menu_options = [ [_('Galaxy Q&A Site'), h.url_for( controller='biostar', action='biostar_redirect', biostar_action='show/tag/galaxy' ), "_blank" ],
                             [_('Ask a question'), h.url_for( controller='biostar', action='biostar_question_redirect' ), "_blank" ] ]
        menu_options.extend( [
            [_('Support'), app.config.get( "support_url", "http://wiki.galaxyproject.org/Support" ), "_blank" ],
            [_('Search'), app.config.get( "search_url", "http://galaxyproject.org/search/usegalaxy/" ), "_blank" ],
            [_('Mailing Lists'), app.config.get( "mailing_lists", "http://wiki.galaxyproject.org/MailingLists" ), "_blank" ],
            [_('Videos'), app.config.get( "videos_url", "http://vimeo.com/galaxyproject" ), "_blank" ],
            [_('Wiki'), app.config.get( "wiki_url", "http://galaxyproject.org/" ), "_blank" ],
            [_('How to Cite Galaxy'), app.config.get( "citation_url", "http://wiki.galaxyproject.org/CitingGalaxy" ), "_blank" ]
        ] )
        if app.config.get( 'terms_url', None ) is not None:
            menu_options.append( [_('Terms and Conditions'), app.config.get( 'terms_url', None ), '_blank'] )
        tab( "help", _("Help"), None, menu_options=menu_options )
            
        
        # SOURCE LINE 190
        __M_writer(u'\n    \n')
        # SOURCE LINE 193
        __M_writer(u'    ')
  
        # Menu for user who is not logged in.
        menu_options = [ [ _("Login"), h.url_for( controller='/user', action='login' ), "galaxy_main" ] ]
        if app.config.allow_user_creation:
            menu_options.append( [ _("Register"), h.url_for( controller='/user', action='create', cntrller='user' ), "galaxy_main" ] ) 
        extra_class = "loggedout-only"
        visible = ( trans.user == None )
        tab( "user", _("User"), None, visible=visible, menu_options=menu_options )
        
        # Menu for user who is logged in.
        if trans.user:
            email = trans.user.email
        else:
            email = ""
        menu_options = [ [ '<a>Logged in as <span id="user-email">%s</span></a>' %  email ] ]
        if app.config.use_remote_user:
            if app.config.remote_user_logout_href:
                menu_options.append( [ _('Logout'), app.config.remote_user_logout_href, "_top" ] )
        else:
            menu_options.append( [ _('Preferences'), h.url_for( controller='/user', action='index', cntrller='user' ), "galaxy_main" ] )
            menu_options.append( [ 'Custom Builds', h.url_for( controller='/user', action='dbkeys' ), "galaxy_main" ] )
            logout_url = h.url_for( controller='/user', action='logout' )
            menu_options.append( [ 'Logout', logout_url, "_top" ] )
            menu_options.append( None )
        menu_options.append( [ _('Saved Histories'), h.url_for( controller='/history', action='list' ), "galaxy_main" ] )
        menu_options.append( [ _('Saved Datasets'), h.url_for( controller='/dataset', action='list' ), "galaxy_main" ] )
        menu_options.append( [ _('Saved Pages'), h.url_for( controller='/page', action='list' ), "_top" ] )
        menu_options.append( [ _('API Keys'), h.url_for( controller='/user', action='api_keys', cntrller='user' ), "galaxy_main" ] )
        if app.config.use_remote_user:
            menu_options.append( [ _('Public Name'), h.url_for( controller='/user', action='edit_username', cntrller='user' ), "galaxy_main" ] )
        
        extra_class = "loggedin-only"
        visible = ( trans.user != None )
        tab( "user", "User", None, visible=visible, menu_options=menu_options )
            
        
        # SOURCE LINE 227
        __M_writer(u'\n    \n')
        # SOURCE LINE 231
        __M_writer(u'    </ul>\n\n    </div>\n    </div>\n    \n')
        # SOURCE LINE 237
        __M_writer(u'    <div class="navbar-brand">\n        <a href="')
        # SOURCE LINE 238
        __M_writer(unicode(h.url_for( app.config.get( 'logo_url', '/' ) )))
        __M_writer(u'">\n        <img border="0" src="')
        # SOURCE LINE 239
        __M_writer(unicode(h.url_for('/static/images/galaxyIcon_noText.png')))
        __M_writer(u'">\n        Galaxy / MGEScan\n')
        # SOURCE LINE 241
        if app.config.brand:
            # SOURCE LINE 242
            __M_writer(u'            <span>/ ')
            __M_writer(unicode(app.config.brand))
            __M_writer(u'</span>\n')
            pass
        # SOURCE LINE 244
        __M_writer(u'        </a>\n    </div>\n\n    <div class="quota-meter-container"></div>\n\n')
        return ''
    finally:
        context.caller_stack._pop_frame()


def render_javascripts(context):
    context.caller_stack._push_frame()
    try:
        h = context.get('h', UNDEFINED)
        parent = context.get('parent', UNDEFINED)
        __M_writer = context.writer()
        # SOURCE LINE 6
        __M_writer(u'\n')
        # SOURCE LINE 7
        __M_writer(unicode(parent.javascripts()))
        __M_writer(u'\n\n<!-- quota meter -->\n')
        # SOURCE LINE 10
        __M_writer(unicode(h.templates( "helpers-common-templates", "template-user-quotaMeter-quota", "template-user-quotaMeter-usage" )))
        __M_writer(u'\n')
        # SOURCE LINE 11
        __M_writer(unicode(h.js( "mvc/base-mvc", "utils/localization", "mvc/user/user-model", "mvc/user/user-quotameter" )))
        __M_writer(u'\n')
        return ''
    finally:
        context.caller_stack._pop_frame()


def render_late_javascripts(context):
    context.caller_stack._push_frame()
    try:
        def get_user_json():
            return render_get_user_json(context)
        parent = context.get('parent', UNDEFINED)
        __M_writer = context.writer()
        # SOURCE LINE 40
        __M_writer(u'\n')
        # SOURCE LINE 41
        __M_writer(unicode(parent.late_javascripts()))
        __M_writer(u'\n<script type="text/javascript">\n\n    // start a Galaxy namespace for objects created\n    window.Galaxy = window.Galaxy || {};\n\n    // set up the quota meter (And fetch the current user data from trans)\n    Galaxy.currUser = new User( ')
        # SOURCE LINE 48
        __M_writer(unicode(get_user_json()))
        __M_writer(u" );\n    Galaxy.quotaMeter = new UserQuotaMeter({\n        model   : Galaxy.currUser,\n        el      : $( document ).find( '.quota-meter-container' )\n    }).render();\n\n</script>\n")
        return ''
    finally:
        context.caller_stack._pop_frame()


def render_get_user_json(context):
    context.caller_stack._push_frame()
    try:
        AssertionError = context.get('AssertionError', UNDEFINED)
        int = context.get('int', UNDEFINED)
        h = context.get('h', UNDEFINED)
        float = context.get('float', UNDEFINED)
        util = context.get('util', UNDEFINED)
        trans = context.get('trans', UNDEFINED)
        __M_writer = context.writer()
        # SOURCE LINE 14
        __M_writer(u'\n')
        # SOURCE LINE 15

        """Bootstrapping user API JSON"""
        #TODO: move into common location (poss. BaseController)
        if trans.user:
            user_dict = trans.user.to_dict( view='element', value_mapper={ 'id': trans.security.encode_id,
                                                                                 'total_disk_usage': float } )
            user_dict['quota_percent'] = trans.app.quota_agent.get_percent( trans=trans )
        else:
            usage = 0
            percent = None
            try:
                usage = trans.app.quota_agent.get_usage( trans, history=trans.history )
                percent = trans.app.quota_agent.get_percent( trans=trans, usage=usage )
            except AssertionError, assertion:
                # no history for quota_agent.get_usage assertion
                pass
            user_dict = {
                'total_disk_usage'      : int( usage ),
                'nice_total_disk_usage' : util.nice_size( usage ),
                'quota_percent'         : percent
            }
        
        
        # SOURCE LINE 36
        __M_writer(u'\n')
        # SOURCE LINE 37
        __M_writer(unicode(h.to_json_string( user_dict )))
        __M_writer(u'\n')
        return ''
    finally:
        context.caller_stack._pop_frame()


def render_title(context):
    context.caller_stack._push_frame()
    try:
        __M_writer = context.writer()
        # SOURCE LINE 4
        __M_writer(u'Galaxy')
        return ''
    finally:
        context.caller_stack._pop_frame()


