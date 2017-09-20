import * as React from 'react';
import { observer } from 'utils';
import { project } from 'app/model';
import { Center } from 'components';

@observer class StatusBar extends React.Component {

    static statusHeight = 16;

    props:{
        /** Width */
        width:number,
        /** Top */
        top:number,
        /** Disabled */
        disabled?:boolean,
        /** onChange */
        onChange?:(value:string) => void
    };

    render() {

        let color = '#FFFFFF';
        if (project.ui.statusBarTextKind === 'success') {
            color = '#00FF00';
        }
        else if (project.ui.statusBarTextKind === 'failure') {
            color = '#FF0000';
        }
        else if (project.ui.statusBarTextKind === 'warning') {
            color = '#FFFF00';
        }

        let colorBis = '#FFFFFF';
        if (project.ui.statusBarBisTextKind === 'success') {
            colorBis = '#00FF00';
        }
        else if (project.ui.statusBarBisTextKind === 'failure') {
            colorBis = '#FF0000';
        }
        else if (project.ui.statusBarBisTextKind === 'warning') {
            colorBis = '#FFFF00';
        }

        return (
            <div
                className="statusbar"
                style={{
                    width: this.props.width,
                    height: StatusBar.statusHeight - 1,
                    position: 'absolute',
                    left: 0,
                    top: this.props.top
                }}
            >
                <div
                    className="statusbar-text"
                    style={{
                        color: color
                    }}
                >
                    {project.ui.statusBarText}
                    {project.ui.statusBarBisText ?
                    <span>
                        {project.ui.statusBarText ?
                            <span className="separator" />
                        : null}
                        <span
                            style={{
                                color: colorBis
                            }}
                        >
                            {project.ui.statusBarBisText}
                        </span>
                    </span>
                    : null}
                </div>
            </div>
        );

    } //render

}

export default StatusBar;